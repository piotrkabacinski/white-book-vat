require 'json'
require 'net/https'

# Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one.
require "bundler"
Bundler.require

Dotenv.load ".env"
DATE = Time.now.strftime("%Y-%m-%d")

# Initiate session
session = GoogleDrive::Session.from_service_account_key(ENV["SERVICE_ACCOUNT_FILE"])

# Get spreadsheet
spreadsheet = session.spreadsheet_by_title(ENV["SPREADSHEET_TITLE"])
worksheet = spreadsheet.worksheets.first

CHECKS = []
# CHECKS = [{
#   :nip => "1132644290",
#   :account => "25109025900000000144348836",
#   :found => false,
#   :valid => nil
# },
# {
#   :nip => "9512357282",
#   :account => "32249000050000460026752159",
#   :found => false,
#   :valid => nil
# }]

# Drop first row since it contains only columns labels
worksheet.rows.drop(1).each do |nip, account|
  CHECKS.push({
    :nip => nip,
    :account => account,
    :found => false,
    :valid => nil
  })
end

NIPS = CHECKS.map { |check| "#{check[:nip]}" }.join ","
uri = URI("#{ENV["MF_API_BASE"]}/api/search/nips/#{NIPS}?date=#{DATE}")

RESPONSE = Net::HTTP.get_response(uri)

if (RESPONSE.code != 200)
  puts JSON.parse(RESPONSE.body)["message"]
  exit
end

RESULTS = JSON.parse RESPONSE.body

# RESULTS = {"result"=>{"subjects"=>[{"name"=>"PIOTR KABACIŃSKI", "nip"=>"1132644290", "statusVat"=>"Czynny", "regon"=>"364389912", "pesel"=>nil, "krs"=>nil, "residenceAddress"=>"MORDECHAJA ANIELEWICZA 28A/38, 01-052 WARSZAWA", "workingAddress"=>nil, "representatives"=>[], "authorizedClerks"=>[], "partner
# s"=>[], "registrationLegalDate"=>"2016-05-11", "registrationDenialBasis"=>nil, "registrationDenialDate"=>nil, "restorationBasis"=>nil, "restorationDate"=>nil, "removalBasis"=>nil, "removalDate"=>nil, "accountNumbers"=>["25109025900000000144348836"], "hasVirtualAccounts"=>false}, {"name"=>"CODE
#  QUEST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ", "nip"=>"9512357282", "statusVat"=>"Czynny", "regon"=>"146176183", "pesel"=>nil, "krs"=>"0000424452", "residenceAddress"=>nil, "workingAddress"=>"ZAMIANY 8/LU202, 02-786 WARSZAWA", "representatives"=>[], "authorizedClerks"=>[], "partners"=>[], "r
# egistrationLegalDate"=>"2014-01-10", "registrationDenialBasis"=>nil, "registrationDenialDate"=>nil, "restorationBasis"=>nil, "restorationDate"=>nil, "removalBasis"=>nil, "removalDate"=>nil, "accountNumbers"=>["32249000050000460026752159", "97249000050000460046279708", "872490000500004600365897
# 82", "06249000050000460057820466", "44249000050000452059433261", "95249010570000990273627647", "07249010570000990073627647", "72249000050000460015588679", "42249010570000990373627647", "51249010570000990173627647"], "hasVirtualAccounts"=>false}], "requestDateTime"=>"29-02-2020 14:07:07", "requ
# estId"=>"4nj80-86j5fni"}}

CHECKS.each do |check|
  record = RESULTS["result"]["subjects"].find { |subject| subject["nip"] == check[:nip] }

  if record != nil
    check[:found] = true
    check[:valid] = record["accountNumbers"].find { |account| account == check[:account] } != nil
  end
end

puts CHECKS