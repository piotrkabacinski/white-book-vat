require 'dotenv'
require 'webmock/rspec'
include WebMock::API

# require 'httplog'

Dotenv.load ".env"

require './src/white_book'

describe WhiteBook::VAT do
  it "Should be initiated" do
    expect(subject).to be_an(WhiteBook::VAT)
  end

  it "Should create accounts list" do
    # stub_request(:post, /googleapis/).to_return(status: 200, body: '{"access_token":"foo","expires_in":9999,"token_type":"Bearer"}')

    subject.create_accounts_list
    expect(subject.create_accounts_list).to be 4
  end


  # before(:all) do
  #   @vat = VAT.new
  # end

  # it "Should create accounts list" do
  #   @vat.create_accounts_list
  #   expect(@vat.accounts.size).to be 4
  # end

  # it "Should create accounts data" do
  #   @vat.create_accounts_data
  #   expect(@vat.accounts_data).not_to be nil
  # end

  # it "Should return results hash" do
  #   keys = @vat.check_accounts().keys

  #   expect(keys.index(:accounts)).not_to be nil
  #   expect(keys.index(:confimation_response)).not_to be nil
  # end

  # it "Should generate proper results" do
  #   results = @vat.check_accounts[:accounts]

  #   expect(results.select { |result| result[:found] }.size).to be 3
  #   expect(results[2][:valid]).to be false
  #   expect(results[3][:found]).to be false
  #   expect(results[3][:valid]).to be nil
  # end
end
