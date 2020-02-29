# White Book Project

## Setup

[Google Sheets and Ruby](https://www.youtube.com/watch?v=VqoSUSy011I) tutorial.

* Create new project in [Google API Console](https://console.developers.google.com/)
* Elable Google Drive and Sheets API for the project (Library > *Selected API* > Enable)
* Go to Credentials ("Dane logowania"):
  1. "Utwórz dane logowania" > "Konto usługi" > "Dalej"
  2. Rola: "Przeglądający > "Dalej"
  3. "Utwórz klucz" > "Typ: JSON" > "Utwórz" (save file in project's root as `service_account.json`).
  4. Save
* In Google Sheet App: "Share" and share sheet with user from `client_email` key in `service_account.json`.

`bundle install`
`bundle exec ruby app.rb`

## Spreadsheet structure

|NIP|Account|
|-|-|
`/[0-9]/`|`/[0-9]/`

## TODO

* ~~Read data from Google Sheets via API~~
* Request data from [MF API](https://wl-api.mf.gov.pl/)
* Store results and confirmation PDF to S3
* Return results and link to confirmation package in response
