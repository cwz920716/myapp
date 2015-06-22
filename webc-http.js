var http = require("http");

var options = {
	host: '10.3.3.1',
	port: 3000,
	method: 'GET',
	path: '/query?qid=1'
};

callback = function(response) {
    var diff = process.hrtime(begin);
    console.log('End-to-End Delay = %d ms', (diff[0] * 1e9 + diff[1]) / 1e6 );
    // console.log(body);
}


var req = http.request(options, callback);
req.setNoDelay(true);
var begin = process.hrtime();
req.end();
