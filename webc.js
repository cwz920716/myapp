var request = require("request");

var i = parseInt(process.argv[2], 10);
var link = "http://9.3.61.168:3000/query?qid=" + i; 

var begin = process.hrtime();

request({
  uri: link,
  method: "GET",
  timeout: 10000,
  followRedirect: true,
  maxRedirects: 10
}, function(error, response, body) {
  var diff = process.hrtime(begin);
  console.log('End-to-End Delay = %d ns', diff[0] * 1e9 + diff[1]);
  // console.log(body);
});
