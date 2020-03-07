require "./src/white_book"
include WhiteBook

def handler(event: nil, context: nil)
  begin
    sheet_raw_data = context != nil ? JSON.parse(event["body"])["data"] : nil

    vat = VAT.new sheet_raw_data

    results = vat.create_accounts_list
                 .create_accounts_data
                 .check_accounts

    confirmation_url = vat.store

    {
      statusCode: 200,
      body: JSON.generate({
        results: results[:accounts],
        request_id: results[:request_id],
        date_time: results[:date_time],
        confirmation_url: confirmation_url
      })
    }
  rescue StandardError => e
    {
      statusCode: 422,
      body: JSON.generate(e)
    }
  end
end

# To launch script locally, uncomment this line:
# puts handler
