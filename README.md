# White Book VAT

Check VAT bank accounts using [MF API](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat) and Google Sheets.

## Setup

* Create new project in [Google API Console](https://console.developers.google.com/)
* Enable Google Drive and Sheets API for the project (Library > *Selected API* > Enable)
* Go to Credentials section:
  * Create Credentials > Service account > Create
  * Role: "Borwser" > Continue
  * Create kye > Key type: JSON > Create
  * Save file in project's root.
* In Google Sheets App: share selected sheet with user from `client_email` key in service account json file
* Create .env file based on .env.template (`cp .env.template .env`) and add shared Sheet's files title and json service account file name

```
$ bundle install
$ ruby app.rb
```

## Tests

```
rspec src/white_book.spec.rb
```

## Spreadsheet structure

Sheet requires two columns for NIP and account number, proceeded by label:

|NIP|Account|
|-|-|
`/[0-9]/`|`/[0-9]/`

## Docker

```Bash
# Create image and tag it as white-book-vat
docker build -t white-book-vat .

# Run container and start session using bash shell
docker run -it white-book-vat bash

ruby app.rb
```

## TODO

* ~~Read data from Google Sheets via API~~
* ~~Request data from [MF API](https://wl-api.mf.gov.pl/)~~
* ~~Return results~~
* ~~Tests~~
* Deploy to AWS Lambda
* Create UI

