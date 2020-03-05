# "Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one."
require "bundler"
Bundler.require
Dotenv.load ".env"

require 'httplog'

require './src/white_book'

def handler(event:, context:)
  vat = WhiteBook::VAT.new
  results = nil

  begin
    results = vat.create_accounts_list
                 .create_accounts_data
                 .check_accounts

    {
      statusCode: 200,
      body: JSON.generate(results[:accounts])
    }
  rescue StandardError => e
    {
      statusCode: 422,
      body: JSON.generate(e)
    }
  end
end
