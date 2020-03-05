require 'json'
require 'net/https'
require "fileutils"
require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"

module WhiteBook
  class VAT
    attr_reader :accounts, :accounts_data, :confimation_response

    def initialize
      @accounts = []
      @accounts_data = nil
      @confimation_response = nil
    end

    def get_accounts_list
      rows = request_accounts_list

      # Drop first row since it contains only columns labels
      rows.drop(1).each do |nip, account|
        accounts.push({
          :nip => nip,
          :account => account,
          :found => false,
          :valid => nil
        })
      end

      self
    end

    def get_accounts_data
      accounts_data = request_accounts_data

      @confimation_response = accounts_data
      @accounts_data = JSON.parse accounts_data

      self
    end

    def check_accounts
      if accounts.size == 0 || accounts_data == nil
        return
      end

      accounts.each do |check|
        record = self.accounts_data["result"]["subjects"].find { |subject| subject["nip"] == check[:nip] }

        if record != nil
          check[:found] = true
          check[:valid] = record["accountNumbers"].find { |account| account == check[:account] } != nil
        end
      end

      {
        :accounts => accounts,
        :confimation_response => confimation_response
      }
    end

    private

    def request_accounts_data
      if accounts.size == 0
        return nil
      end

      uri = create_request_URI
      response = Net::HTTP.get_response(uri)

      if (response.code != "200")
        raise "#{JSON.parse(response.body)["message"]}"
      end

      response.body
    end

    def request_accounts_list
      sheet = GoogleSheet.new
      sheet.sheet
    end

    def create_request_URI
      nips = accounts.map { |account| "#{account[:nip]}" }.join ","
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
      range = "A1:C"
      response = service.get_spreadsheet_values spreadsheet_id, range

      raise "No data found." if response.values.empty?

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
end
