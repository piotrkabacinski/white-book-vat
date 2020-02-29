require_relative 'src/white_book'

VAT = WhiteBook::VAT.new
results = nil

begin
  results = VAT.get_accounts_list()
               .request_accounts_data()
               .check_accounts()
               .accounts
rescue StandardError => e
  puts "An error occurred:"
  puts e
  exit
end

puts results