require "dotenv"
require "webmock/rspec"
require "./src/white_book"

include WebMock::API
include WhiteBook

describe VAT do
  before(:each) do
    date = Time.now.strftime("%Y-%m-%d")

    stub_request(:post, /www.googleapis.com/).to_return(
      status: 200,
      body: '{"access_token":"foo","expires_in":0,"token_type":"Bearer"}',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, /sheets.googleapis/).to_return(
      status: 200,
      body: '{ "values": [ [ "", "12-3" ], [ "", "456" ], [ "", "" ], [ "", "000" ] ] }',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/123?date=#{date}").to_return(
      status: 200,
      body: '{"result": {"subjects": [{"name": "Foo bar", "nip": "1002003000", "statusVat": "Czynny", "accountNumbers": ["123"], "hasVirtualAccounts": false } ], "requestId": "abc-123" } }',
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/456?date=#{date}").to_return(
      status: 200,
      body: '{"result": {"subjects": [{"name": "Baz", "nip": "9002005000", "statusVat": "Czynny", "accountNumbers": ["900"], "hasVirtualAccounts": true } ], "requestId": "defg-123"} }',
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/000?date=#{date}").to_return(
      status: 200,
      body: '{"result":{"subjects":[],"requestId":"foo-987"}}'
    )

    stub_request(:put, /amazonaws.com/).to_return(status: 200)

    subject.create_accounts_list
    subject.create_accounts_data
  end

  it "Should be initiated" do
    expect(subject).to be_an(VAT)
  end

  it "Should remove non digit characteres from account numbers" do
    subject.accounts.each do |account|
      expect(account[:account] =~ /[^0-9]/).to be nil
    end
  end

  it "Should create accounts list" do
    expect(subject.accounts.length).to be 4
  end


  it "Should return today request date when no declared" do
    expect(subject.date).equal? Time.now.strftime("%Y-%m-%d")
  end

  it "Should create accounts data" do
    expect(subject.accounts_data).not_to be nil
  end

  it "Should return results hash" do
    results = subject.check_accounts

    expect(results.key?(:accounts)).to be true
  end

  it "Should generate proper results" do
    results = subject.check_accounts[:accounts]

    expect(results.select { |result| result[:found] }.size).to be 2

    expect(results[0][:found]).to be true
    expect(results[0][:accountFound]).to be true
    expect(results[0][:valid]).to be true
    expect(results[0][:hasVirtual]).to be false
    expect(results[0][:nip]).equal? "1002003000"
    expect(results[0][:requestId]).equal? "abc-123"
    expect(results[0][:checked]).to be true

    expect(results[1][:found]).to be true
    expect(results[1][:valid]).to be true
    expect(results[1][:accountFound]).to be false
    expect(results[1][:hasVirtual]).to be true
    expect(results[1][:nip]).equal? "9002005000"
    expect(results[1][:requestId]).equal? "defg-123"
    expect(results[1][:checked]).to be true

    expect(results[2][:found]).to be false
    expect(results[2][:valid]).to be false
    expect(results[2][:accountFound]).to be false
    expect(results[2][:hasVirtual]).to be false
    expect(results[2][:nip]).equal? nil
    expect(results[2][:requestId]).equal? nil
    expect(results[2][:checked]).to be false

    expect(results[3][:found]).to be false
    expect(results[3][:valid]).to be false
    expect(results[3][:accountFound]).to be false
    expect(results[3][:hasVirtual]).to be false
    expect(results[3][:checked]).to be true
    expect(results[2][:requestId]).equal? "foo-987"
  end

  it "Should store file" do
    path = subject.store
    expect(path).not_to be nil
  end
end
