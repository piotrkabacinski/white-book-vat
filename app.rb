require "./src/white_book"
include WhiteBook

def handler(event:, context:)
  accounts_to_check = JSON.parse(event["body"])["data"]

  vat = VAT.new accounts_to_check

  begin
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

