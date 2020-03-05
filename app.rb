# "Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one."
require "bundler"
Bundler.require
Dotenv.load ".env"

require './src/white_book'

VAT = WhiteBook::VAT.new
results = nil

begin
  results = VAT.get_accounts_list
               .get_accounts_data
               .check_accounts
rescue StandardError => e
  puts "An error occurred:"
  puts e
  exit
end

puts results[:accounts]
