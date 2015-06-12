var http = require('http');

var queries = [ 
				"select * from employees where first_name = 'Anwar'",
				"select * from employees where emp_no = 211972",
				];

var nquery = 2;

var mysql     =    require('mysql');

var pool      =    mysql.createPool({
    connectionLimit : 100, //important
    host     : 'localhost',
    user     : 'root',
    password : 'passwd',
    database : 'employees',
    debug    :  false
});

function handle_database(req, res) {
   
    pool.getConnection(function(err, connection){
        if (err) {
          connection.release();
          res.json({"code" : 100, "status" : "Error in connection database"});
          return;
        }  

        // console.log('connected as id ' + connection.threadId);
       
        connection.query(queries[req.query.qid % nquery], function(err,rows){
            connection.release();
            if(!err) {
                res.json(rows);
            }          
        });

        connection.on('error', function(err) {      
              res.json({"code" : 100, "status" : "Error in connection database"});
              return;    
        });
  });
}

var express = require('express');
var app = express();

app.get('/query', function (req, res) {
        console.log(req.connection.remoteAddress + ":" + req.connection.remotePort);
	var time = process.hrtime();
	// console.log('new request arrived ' + req.hostname);
	handle_database(req, res);
	var diff = process.hrtime(time);
	console.log('req took %d nanoseconds', diff[0] * 1e9 + diff[1]);
	 // res.send('id: ' + req.query.qid);
});

var server = app.listen(3000, function () {

	var host = server.address().address;
	var port = server.address().port;

	console.log('Example app listening at http://%s:%s', host, port);

});
