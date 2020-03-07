function onOpen() {
  var ui = SpreadsheetApp.getUi();

  ui
  .createMenu('Accounts check')
  .addItem('Check data', 'checkData')
  .addToUi();
}

function checkData() {
  var sheet = SpreadsheetApp.getActiveSheet();

  sheet.getRange("C2:C30").clearContent()
  sheet.getRange("D2:D30").clearContent()

  var dateTimeCell = sheet.getRange("G1");
  var requestIdCell = sheet.getRange("G2");
  var confirmationCell = sheet.getRange("G3");

  requestIdCell.clearContent();
  dateTimeCell.clearContent();
  confirmationCell.clearContent();

  var options = {
    'method' : 'post',
    'contentType': 'application/json',
    'payload' : JSON.stringify({
      data: sheet.getRange("A2:B31").getValues()
    })
  };

  var request = UrlFetchApp.fetch('https://hagd2yjnhj.execute-api.eu-west-1.amazonaws.com/default/WhiteBookVat-WhiteBookVAT-GWOM5SUJHK5M', options);
  var response = JSON.parse(request.getContentText());

  // Logger.log(response);

  requestIdCell.setValue(response["request_id"]);
  dateTimeCell.setValue(response["date_time"]);
  confirmationCell.setValue(response["confirmation_url"])

  var initialCell = 2;

  for(var index in response.results) {
    var cell = initialCell + Number(index);

    if (response.results[index]["nip"] !== "") {
      sheet.getRange('C' + cell).setValue(response.results[index]["found"] ? "1" : "0");
      sheet.getRange('D' + cell).setValue(response.results[index]["valid"] ? "1" : "0");
    }
  }
}