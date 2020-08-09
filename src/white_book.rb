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
    attr_reader :accounts, :accounts_data, :confimation_response, :search_id, :date

    def initialize(sheet_raw_data = nil, date = nil)
      @sheet_raw_data = sheet_raw_data
      @date = set_date(date)
      @accounts_data = nil
      @confimation_response = nil
      @request_id = nil
    end

    def set_date(date)
      date && !date.empty? ? date : Time.now.strftime("%Y-%m-%d")
    end

    def create_accounts_list
      sheet = @sheet_raw_data

      if sheet == nil
        source_sheet = GoogleSheet.new
        sheet = source_sheet.sheet
      end

      @accounts = sheet.map do |nip, account|
        {
          account: account.to_s.tr('^0-9', ''),
          accountFound: false,
          company: nil,
          found: false,
          nip: nil,
          requestId: nil
          valid: false,
          virtual: false,
        }
      end

      @accounts
    end

    def create_accounts_data
      mf_api = MfAPI.new(@date)

      accounts_data = []

      @accounts.each { |subject|
        if subject[:account] == ""
          accounts_data.push(nil)
          next
        end

        account_data = mf_api.account_data(subject[:account])
        accounts_data.push(JSON.parse(account_data))
      }

      @confimation_response = accounts_data.freeze
      @accounts_data = accounts_data

      @accounts_data
    end

    def check_accounts
      if accounts.size == 0 || accounts_data == nil
        return
      end

      accounts.each_with_index do |record, index|
        next if record.nil?
        next if accounts_data[index].nil?

        response_data = accounts_data[index]["result"]["subjects"].first

        record[:accountFound] = response_data["accountNumbers"].find { |bankAccount|
          bankAccount == record[:account]
        }

        record[:found] = true
        record[:valid] = response_data["statusVat"] == "Czynny"
        record[:nip] = response_data["nip"]
        record[:hasVirtualAccounts] = response_data["hasVirtualAccounts"]
        record[:company] = response_data["name"]
        record[:requestId] = accounts_data[index]["requestId"]
      end

      {
        accounts: accounts,
        date: @date
      }
    end

    def store
      return nil if confimation_response == nil

      file = BucketS3.new(confimation_response, @date)
      file.store
    end
  end

  class MfAPI
    def initialize(date = nil)
      @date = date
    end

    def account_data(account_number = nil)
      return nil if account_number == nil

      uri = mf_uri(account_number)

      response = Net::HTTP.get_response(uri)

      if (response.code != "200")
        raise "#{JSON.parse(response.body)["message"]}"
      end

      response.body
    end

    private

    def mf_uri(bank_account)
      URI("#{ENV["MF_API_BASE"]}/api/search/bank-accounts/#{bank_account}?date=#{@date}")
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
    def initialize(confirmationJson, date = nil)
      @content_to_save = confirmationJson
      # AWS Lambda requires to store files in /tmp/ directory to be accesable
      @dir = "/tmp/"
      @date = date
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

      request_date = Time.now.strftime("%Y-%m-%d_$H%i%s")
      file_name = "#{request_date}_confirmation.json"

      out_file = File.new(@dir + file_name, "w")
      out_file.puts(@content_to_save)
      out_file.close

      file_name
    end
  end
end
