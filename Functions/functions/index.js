const functions = require('firebase-functions');
const admin = require('firebase-admin')
admin.initializeApp();

//initialize dropbox
// var Dropbox = require('dropbox').Dropbox;
// var dbx = new Dropbox({ accessToken: functions.config().dropbox.access_token });

//schedule example
exports.scheduledCVPredict = functions.pubsub.schedule('every 4 minutes')
    .timeZone("Australia/Sydney")
    .onRun((context) => {
    console.log('Call Custom Vision Prediction API here');
    return null;
  });

//file download example
// dbx.filesDownload({ path: '' }).then(function (response) {
//     var results = document.getElementById('results');
//     results.appendChild(document.createTextNode('File Downloaded!'));
//     console.log(response);
// }).catch(function (error) {
//     console.error(error);
// });

