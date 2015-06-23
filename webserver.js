var http = require('http');
url = require('url');

var queries = [ 
		"select * from employees where emp_no = 211972",
		"show databases",
		"show tables",
		"describe employees",
		"describe salaries",
		"select emp_no, first_name, last_name, gender from employees limit 10",
		"select emp_no, first_name, last_name, gender from employees order by last_name asc, first_name asc limit 10",
		"select count(emp_no) from employees where last_name = 'Aamodt'",
		"select last_name, count(emp_no) as num_emp from employees group by last_name order by num_emp desc limit 10",
		"select count(emp_no) as NumEmployees from employees",
		"select count(emp_no) as NumSalaries from salaries",
		"select count(distinct emp_no) as NumDistinctSalaries from salaries",
		"select sa.salary, em.emp_no from salaries as sa join employees as em on sa.emp_no = em.emp_no order by sa.salary desc limit 10",
		"select sa.salary, em.emp_no from salaries as sa inner join employees as em on sa.emp_no = em.emp_no order by sa.salary desc limit 20",
		"select sa.salary, em.emp_no from employees as em left join salaries as sa on sa.emp_no = em.emp_no order by sa.salary desc limit 30",
		"select sa.salary, em.emp_no from employees as em right outer join salaries as sa on sa.emp_no = em.emp_no order by sa.salary desc limit 40",
		"select * from salaries where emp_no in (254466, 47978, 253939)",
		"select * from employees where emp_no in (254466, 47978, 237542)",
		];

var nquery = 18;

var mysql     =    require('mysql');

var pool      =    mysql.createPool({
    connectionLimit : 1000, //important
    host     : 'localhost',
    user     : 'root',
    password : 'passwd',
    database : 'employees',
    debug    :  false
});

function handle_database(req, res) {
    var sql_time = process.hrtime();
   
    pool.getConnection(function(err, connection){
        if (err) {
          connection.release();
          res.json({"code" : 100, "status" : "Error in connection database"});
          return;
        }  

        // console.log('connected as id ' + connection.threadId);

	var queryId = url.parse(req.url, true).query.qid;
	if (queryId == nquery) {
		queryId = Math.floor( Math.random() * nquery );
	} 
//        console.log('qId as id ' + queryId);
	     
        connection.query(queries[queryId % nquery], function(err,rows){
            connection.release();
            if(!err) {
                res.json(rows);
	        var diff2 = process.hrtime(sql_time);
	        console.log('mysql-ref is %d', (diff2[0] * 1e9 + diff2[1]) / 1e6);
            }          
        });

        connection.on('error', function(err) {      
              res.json({"code" : 100, "status" : "Error in connection database"});
              return;    
        });
  });
}

function pausecomp(millis)
{
	var time = process.hrtime();
	var diff = process.hrtime(time);
	do { diff = process.hrtime(time); }
	while((diff[0] * 1e9 + diff[1]) / 1e6 < millis);
}

var restify = require('restify');
var app = restify.createServer();

var sleep = require('sleep');

app.get('/query', function (req, res, next) {
  //      console.log(req.connection.remoteAddress + ":" + req.connection.remotePort);
	var recv_time = process.hrtime();
	if (url.parse(req.url, true).query.qid == -1) {
		var sleepms = Math.random();
		i = i + 1;	
		var sleepus = Math.floor(sleepms * 1000);	
		/* setTimeout(
			function() {
				console.log('req sleep %d milliseconds', sleepms);
				res.send('Sleep for randome ms!');
			},
			sleepms); */
		pausecomp(sleepms);
		res.send('Sleep for randome ms!');
	} else {
		handle_database(req, res);
	}
	var diff = process.hrtime(recv_time);
	console.log('%d', (diff[0] * 1e9 + diff[1]) / 1e6);
//	console.log('id: ' + url.parse(req.url, true).query.qid);
	return next();
});

// var fs = require('fs');
// var array = fs.readFileSync('seeds.txt').toString().split("\n");
// var i = 0;

app.use(restify.acceptParser(app.acceptable));
app.use(restify.dateParser());
app.use(restify.queryParser());
app.use(restify.bodyParser());
var server = app.listen(3000, function () {

	var host = server.address().address;
	var port = server.address().port;

//	console.log('Example app listening at http://%s:%s', host, port);

});
