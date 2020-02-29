# White Book Project

## Setup

[Google Sheets and Ruby](https://www.youtube.com/watch?v=VqoSUSy011I) tutorial.

* Create new project in [Google API Console](https://console.developers.google.com/)
* Elable Google Drive and Sheets API for the project (Library > *Selected API* > Enable)
* Go to Credentials ("Dane logowania"):
  1. "Utwórz dane logowania" > "Konto usługi" > "Dalej"
  2. Rola: "Przeglądający > "Dalej"
  3. Utwórz klucz > Type: JSON > Utwórz (save file in project's root as `service_account.json`).
  4. Save
* In Google Sheet App: go to "Share" and share sheet with user from `client_email` key in `service_account.json`.

`bundle install`
