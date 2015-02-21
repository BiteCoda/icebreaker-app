"use strict";

// Declare a Token object that will be used to store a device token and its type
var Token = function(deviceToken, deviceType){
	var newToken = {};
	newToken.deviceToken = deviceToken;
	newToken.deviceType = deviceType;
	return newToken;
}

var Message = function(message, errors)
{
	return {msg: message, errors: errors};
}

// This is going to be used as the global store for all the mappings ids to device tokens
// Is a dictionary where the key is the the estimote id and the value is a Token object
// Later, we'll want to use a database to store these mappings for a better, more reliable solution
var idToDeviceMappings = [];

// Create the server object to use for handling http requests
var restify = require('restify');
var server = restify.createServer();

// Configure the server to parse the parameters in the body/url into arrays
server.use(restify.queryParser());
server.use(restify.bodyParser());

// Configure the server to always return gzipped responses for faster
server.use(restify.gzipResponse());

// Listen to subscribe requests
server.post('/subscribe', function(req, res, next) {
	var reqObject = JSON.parse(req.params['request']);
	var newToken = Token(reqObject.deviceToken, reqObject.deviceType);
	var userId = reqObject.userId;
	idToDeviceMappings[userId] = newToken;
	console.log("The user Id: " + userId + " was mapped to: " + newToken);
	res.send(200, Message("Added device to subscribers list!", null));
});

// Start listening to requests on port 3000
server.listen(3000, function(){
	console.log('%s listening at %s', server.name, server.url);
});