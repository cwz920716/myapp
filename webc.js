var request = require("request");

var i = parseInt(process.argv[2], 10);
var link = "http://10.3.3.1:3000/query?qid=" + i; 

var begin = process.hrtime();

var req = request({
  uri: link,
  method: "GET",
  timeout: 10000,
  followRedirect: true,
  maxRedirects: 10,
  time: true
}, function(error, response, body) {
  var diff = process.hrtime(begin);
  console.log('End-to-End Delay = %d ms', (diff[0] * 1e9 + diff[1]) / 1e6 );
  // console.log(body);
});
