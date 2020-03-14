require "aws-sdk-s3"
require "dotenv"
require "fileutils"
require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "json"
require "net/https"

Dotenv.load ".env"

module WhiteBook
  class VAT
    attr_reader :accounts, :accounts_data, :confimation_response, :search_id

    def initialize(sheet_raw_data = nil)
      @sheet_raw_data = sheet_raw_data
      @accounts_data = nil
      @confimation_response = nil
      @request_id = nil
    end

    def create_accounts_list
      sheet = @sheet_raw_data

      if sheet == nil
        source_sheet = GoogleSheet.new
        sheet = source_sheet.sheet
      end

      @accounts = sheet.map do |nip, account|
        {
          nip: nip.to_s.tr('^0-9', ''),
          account: account.to_s.tr('^0-9', ''),
          found: false,
          valid: nil
        }
      end

      @accounts
    end

    def create_accounts_data
      mf_api = MfAPI.new accounts
      accounts_data = mf_api.accounts_data

      @confimation_response = accounts_data.freeze
      @accounts_data = JSON.parse accounts_data
      @request_id = @accounts_data["result"]["requestId"]

      @accounts_data
    end

    def check_accounts
      if accounts.size == 0 || accounts_data == nil
        return
      end

      accounts.each do |check|
        record = self.accounts_data["result"]["subjects"].find { |subject| subject["nip"] == check[:nip] }

        next if record.nil?

        check[:found] = true
        check[:valid] = record["accountNumbers"].find { |account| account == check[:account] }.nil? == false
      end

      {
        accounts: accounts,
        date_time: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        request_id: @request_id,
        confimation_response: confimation_response,
      }
    end

    def store
      return nil if confimation_response == nil

      file = BucketS3.new confimation_response
      file.store
    end
  end

  class MfAPI
    def initialize(accounts)
      @accounts = accounts
    end

    def accounts_data
      return nil if @accounts.size.zero?

      uri = mf_uri
      response = Net::HTTP.get_response(uri)

      if (response.code != "200")
        raise "#{JSON.parse(response.body)["message"]}"
      end

      response.body
    end

    private

    def mf_uri
      nips = @accounts.map { |account| "#{account[:nip]}" }.join ","
      date = Time.now.strftime("%Y-%m-%d")

      URI("#{ENV["MF_API_BASE"]}/api/search/nips/#{nips}?date=#{date}")
    end
  end

  class GoogleSheet
    def sheet
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = "White Book VAT"
      service.authorization = authorizer

      spreadsheet_id = ENV["SPREADSHEET_ID"]
      range = "A6:B36"
      response = service.get_spreadsheet_values spreadsheet_id, range

      raise "No data found in spreadsheet." if response.values.empty?

      response.values
    end

    private

    def authorizer
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(ENV["SERVICE_FILE"]),
        scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
      )
    end
  end

  class BucketS3
    def initialize(confirmationJson)
      @content_to_save = confirmationJson
      # AWS Lambda requires to store files in /tmp/ directory to be accesable
      @dir = "/tmp/"
    end

    def store
      s3 = Aws::S3::Resource.new(region: ENV["S3_REGION"])
      file_name = create_file
      file_path = @dir + file_name

      obj = s3.bucket(ENV["S3_BUCKET"]).object("reports/#{file_name}")

      obj.upload_file(file_path)

      File.delete(file_path) if File.exist?(file_path)

      "https://#{ENV["S3_BUCKET"]}.s3.#{ENV["S3_REGION"]}.amazonaws.com/reports/#{file_name}"
    end

    private

    def create_file
      return unless @content_to_save != nil

      request_id = JSON.parse(@content_to_save)["result"]["requestId"]
      file_name = "#{Time.now.strftime("%Y-%m-%d_%H%M%S")}_#{request_id}_confirmation.json"

      out_file = File.new(@dir + file_name, "w")
      out_file.puts(@content_to_save)
      out_file.close

      file_name
    end
  end
end
