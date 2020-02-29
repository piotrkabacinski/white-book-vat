# "Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one."
require "bundler"
Bundler.require

require_relative 'src/white_book'

WB = WhiteBook.new

puts WB.get_accounts_list()
       .request_accounts_data()
       .check_accounts()
       .accounts
