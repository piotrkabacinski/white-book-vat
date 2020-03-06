require "./src/white_book"
include WhiteBook

# require "httplog"

def handler (event:, context:)
  file = AWSStore.new "{ aws: true }"
  file.store

#   vat = VAT.new
#   results = nil

#   begin
#     results = vat.create_accounts_list
#                  .create_accounts_data
#                  .check_accounts

#     {
#       statusCode: 200,
#       body: JSON.generate(results[:accounts])
#     }
#   rescue StandardError => e
#     {
#       statusCode: 422,
#       body: JSON.generate(e)
#     }
#   end
end

