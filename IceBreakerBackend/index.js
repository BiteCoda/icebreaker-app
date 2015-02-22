"use strict";

// This is going to be used as the global store for all the mappings ids to device tokens
// Is a dictionary where the key is the the estimote id and the value is a Token object
// Later, we'll want to use a database to store these mappings for a better, more reliable solution
var idToDeviceMappings = {};

// Will store the pairs of users that are connected - should also store this in db later
var userPairs = [];

// Create the server object to use for handling http requests
var restify = require('restify');
var server = restify.createServer();
var unirest = require('unirest');
var apn = require('apn');

var syncRequest = require('sync-request');

// Make a connection to apn
var options = {passphrase:'123456789'};
var apnConnection = new apn.Connection(options);

// Configure the server to parse the parameters in the body/url into arrays
server.use(restify.queryParser());
server.use(restify.bodyParser());

// Configure the server to always return gzipped responses for faster
server.use(restify.gzipResponse());

var reqVars = {
	SOURCE_USER:'userId', 
	TARGET_USER:'targetUserId', 
	DEVICE_TOKEN:'deviceToken',
	DEVICE_TYPE:'deviceType'
};

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

var sendNotificationIOS = function(deviceToken, message){

		console.log("In sendNotificationIOS");
		var myDevice = new apn.Device(deviceToken);
		var note = new apn.Notification();

		note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
		note.badge = 3;
		note.sound = "default";
		note.alert = message;

		apnConnection.pushNotification(note, myDevice);
}

var sendNotificationAndroid = function(deviceToken, message){

}

var checkForExistingPairForUsers = function(userOne, userTwo){
	console.log("Inside Check for ExistingPairforUsers");

	for(var i = 0; i < userPairs.length; i++){
		var pair = userPairs[i];
		if(pair.indexOf(userOne) != -1) {
			console.log("The first user already has a pair");
			return 1;
		}
		if(pair.indexOf(userTwo) != -1) {
			console.log("The second user already has a pair");
			return 2;
		}
	}
	// No pair was found, add them to a pair
	userPairs.push([userOne, userTwo]);
	return 0;
}

var unpairUser = function(userId){
	console.log("Inside unpairUser: " + userId);

	for(var i = 0; i < userPairs.length; i++)
	{
		var pair = userPairs[i];
		if(pair.indexOf(userId) != -1)
		{
			userPairs.splice(i,1);
			console.log("Removed Pairing for userId: " + userId);
			break;
		}
	}

	return true;
}

var sendNotificationToUser = function (targetUserId, message) {
	console.log("sendNotificationToUser - targetUserId: " + targetUserId);
	var token = idToDeviceMappings[targetUserId];
	console.log(JSON.stringify(token));
	if(token)
	{
		if(token.deviceType === 'ios'){
			console.log("The device is ios");
			sendNotificationIOS(token.deviceToken, message);
		} else {
			console.log("The device is android...probably");
			sendNotificationAndroid(token.deviceToken, message);
		}
	}
}

var sendAnswerToQuestion = function(targetUserId) {
	console.log("Inside sendAnswerToQuestion");
	var question;

	var res = syncRequest('POST', "https://andruxnet-random-famous-quotes.p.mashape.com/cat=famous",
					{
						headers:{
							"X-Mashape-Key" : "0rLUKP6rEFmshBWVTh3vxVgDZVBbp1OLTdjjsnaBr7xVyYDbWU",
							"Content-Type" 	: "application/x-www-form-urlencoded",
							"Accept" : "application/json"
						}
					});
	var body = JSON.parse(res.getBody());
	console.log(body);
	sendNotificationToUser(targetUserId, body.author);
	console.log("Returning question");
	question = body;
	return question;
}

// Listen to subscribe requests
server.post('/subscribe', function(req, res, next) {
	console.log("Processing Request...");
	var reqObject = req.params;
	var newToken = Token(reqObject[reqVars.DEVICE_TOKEN], reqObject[reqVars.DEVICE_TYPE]);
	var userId = reqObject[reqVars.SOURCE_USER];


	console.log("Storing Device Token...");
	idToDeviceMappings[userId] = newToken;
	console.log("The user Id: " + userId + " was mapped to: " + newToken.deviceToken);
	res.send(200, Message("Added device to subscribers list!", null));
});

server.post('/message', function(req, res, next) {
	var reqObject = req.params;
	var sourceUserId = reqObject[reqVars.SOURCE_USER];
	var targetUserId = reqObject[reqVars.TARGET_USER];
	console.log("Got Parameters from Request: " + sourceUserId + " " + targetUserId);
	var exists = checkForExistingPairForUsers(sourceUserId, targetUserId);
	if(exists == 0){
		console.log("No such pair exists, make it");
		var question = sendAnswerToQuestion(targetUserId);
		res.send(200, question);
	}else
	{
		console.log("The pair existed already");
		res.send(400);
	}
});

server.post('/unpair', function(req, res, next) {
	var reqObject = req.params;
	var userId = reqObject[reqVars.SOURCE_USER];

	console.log("Got parameters from Request: " + userId);
	var test = unpairUser(userId);

	res.send(200, Message("Successfully canceled all pairings for the user", null));
});


// Start listening to requests on port 3000
server.listen(3000, function(){
	console.log('%s listening at %s', server.name, server.url);
});