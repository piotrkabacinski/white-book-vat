require 'json'
require 'net/http'

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

worksheet.rows.drop(1).each do |nip, account|
  CHECKS.push({
    :nip => nip,
    :account => account
  })
end

puts CHECKS
