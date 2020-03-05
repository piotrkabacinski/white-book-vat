require 'rspec'
require './src/white_book'

class VAT < WhiteBook::VAT
  private
  def request_accounts_list
    [
        [ "NIP", "Account" ],
        [ "0000000000", "10030040000005556667779999" ],
        [ "1111111111", "20030040000005556667779998" ],
        [ "222222222", "0" ],
        [ "xxx", "" ]
    ]
  end

  def request_accounts_data
    '{"result":{"subjects":[{"name":"JAN KOWALSKI","nip":"0000000000","statusVat":"Czynny","regon":"999999999","pesel":null,"krs":null,"residenceAddress":"KWIATOWA 1/2, 00-001 WARSZAWA","workingAddress":null,"representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2016-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["10030040000005556667779999"],"hasVirtualAccounts":false},{"name":"FOOBAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ","nip":"1111111111","statusVat":"Czynny","regon":"888888888","pesel":null,"krs":"0000424242","residenceAddress":null,"workingAddress":"WIOSENNA 10, 00-123 WARSZAWA","representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2014-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["20030040000005556667779998","20030040000005556667779997"],"hasVirtualAccounts":false},{"name":"BAZBAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ","nip":"222222222","statusVat":"Czynny","regon":"333333333","pesel":null,"krs":"0000323232","residenceAddress":null,"workingAddress":"ZIMOWA 1, 00-999 WARSZAWA","representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2015-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["30030040000005556667779998","30030040000005556667779997"],"hasVirtualAccounts":false}],"requestDateTime":"29-02-2020 13:56:42","requestId":"m6fg9-11w5eli"}}'
  end
end

describe VAT do
  before(:all) do
    @vat = VAT.new
  end

  it "Should create accounts list" do
    @vat.create_accounts_list
    expect(@vat.accounts.size).to be 4
  end

  it "Should create accounts data" do
    @vat.create_accounts_data
    expect(@vat.accounts_data).not_to be nil
  end

  it "Should return results hash" do
    keys = @vat.check_accounts().keys

    expect(keys.index(:accounts)).not_to be nil
    expect(keys.index(:confimation_response)).not_to be nil
  end

  it "Should generate proper results" do
    results = @vat.check_accounts[:accounts]

    expect(results.select { |result| result[:found] }.size).to be 3
    expect(results[2][:valid]).to be false
    expect(results[3][:found]).to be false
    expect(results[3][:valid]).to be nil
  end
end
