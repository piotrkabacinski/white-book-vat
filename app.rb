require 'json'
require 'net/http'

# Bundler.require sets up the load paths and automatically requires every dependency,
# saving you from having to manually require each one.
require "bundler"
Bundler.require

Dotenv.load ".env"

session = GoogleDrive::Session.from_service_account_key(ENV["SERVICE_ACCOUNT_FILE"])
spreadsheet = session.spreadsheet_by_title(ENV["SPREADSHEET_TITLE"])

worksheet = spreadsheet.worksheets.first
worksheet.rows.first(10).each { |row| puts row.first(5).join(",") }