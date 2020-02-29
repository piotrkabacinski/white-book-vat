require 'json'
require 'net/https'

module WhiteBook
  class VAT
    attr_reader :accounts, :accounts_data

    def initialize()
      @accounts = []
      @accounts_data = nil
    end

    def get_accounts_list
      # Initiate session and get sheet content
      session = GoogleDrive::Session.from_service_account_key(ENV["SERVICE_ACCOUNT_FILE"])
      spreadsheet = session.spreadsheet_by_title(ENV["SPREADSHEET_TITLE"])
      worksheet = spreadsheet.worksheets.first

      # Drop first row since it contains only columns labels
      worksheet.rows.drop(1).each do |nip, account|
        accounts.push({
          :nip => nip,
          :account => account,
          :found => false,
          :valid => nil
        })
      end

      self
    rescue StandardError => e
      puts "An error occured while getting sheet data:"
      raise e
    end

    def request_accounts_data
      if accounts.size == nil
        exit
      end

      uri = create_request_URI
      response = Net::HTTP.get_response(uri)

      if (response.code != "200")
        raise "#{JSON.parse(response.body)["message"]}"
      end

      @accounts_data = JSON.parse response.body

      self
    rescue StandardError => e
      puts "An error occured while gettings accounts data:"
      raise e
    end

    def check_accounts
      accounts.each do |check|
        record = self.accounts_data["result"]["subjects"].find { |subject| subject["nip"] == check[:nip] }

        if record != nil
          check[:found] = true
          check[:valid] = record["accountNumbers"].find { |account| account == check[:account] } != nil
        end
      end

      self
    end

    private

    def create_request_URI
      nips = accounts.map { |account| "#{account[:nip]}" }.join ","
      date = Time.now.strftime("%Y-%m-%d")

      URI("#{ENV["MF_API_BASE"]}/api/search/nips/#{nips}?date=#{date}")
    end
  end
end
