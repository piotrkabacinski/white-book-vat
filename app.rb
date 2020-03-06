require "./src/white_book"
include WhiteBook

def handler(event:, context:)
  vat = VAT.new

  begin
    results = vat.create_accounts_list
                 .create_accounts_data
                 .check_accounts

    confirmation_url = vat.store

    {
      statusCode: 200,
      body: JSON.generate({
        results: results[:accounts],
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

