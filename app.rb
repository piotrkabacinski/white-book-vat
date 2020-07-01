require "./src/white_book"
include WhiteBook

def handler(event: nil, context: nil)
  begin
    sheet_raw_data = event != nil ? JSON.parse(event["body"]) : nil

    date = sheet_raw_data != nil ? sheet_raw_data["date"] : nil
    vat_data = sheet_raw_data != nil ? sheet_raw_data["data"] : nil

    vat = VAT.new vat_data date

    vat.create_accounts_list
    vat.create_accounts_data

    results = vat.check_accounts

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
