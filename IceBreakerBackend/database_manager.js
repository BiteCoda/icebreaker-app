var DATABASE_NAME = 'icebreakers';
var MONGO_URL = 'mongodb://localhost/' + DATABASE_NAME;
var mongoose;

// Collection names
var REGISTRATION_COLLECTION = 'registration'

// Schemas
var registrationSchema;
var pairedUserSchema;

// Models
var registrationModel;
var pairedUserModel;

module.exports = {

    initialize: function() {

        var mongoose = require('mongoose');
        mongoose.connect(MONGO_URL);

        var db = mongoose.connection;
        db.on('error', console.error.bind(console, 'connection error:'));
        db.once('open', function (callback) {

            setupSchemas();
            setupModels();
            setupVirtuals();

        });

    }

    /*
    *   Registration Model functions
    */

    createRegistrationObject: function(userId, deviceToken, deviceType) {

        var registrationObject = new registrationModel({
            userId: userId,
            deviceToken: deviceToken,
            deviceType: deviceType
        });

        registrationObject.save(function (err, registrationObject) {
            if (err) {
                // hande error
                return console.error(err);
            } else {
                // Save Successful
                console.log('Save successful');
            }
        });

        return registrationObject;

    }

    function getDeviceTokenByUserId(userId) {

        registrationModel.findOne({userId: userId}, 'deviceToken', function (err, deviceToken) {

            if (err) {
                // handle error
                console.log(err);
                return;
            }

            if (deviceToken) {
                return deviceToken;
            }

        });
    }

    /*
    *   PairedUser Model functions
    */

    function createPairedUserObject(primaryUserId, secondaryUserId) {

        var pairedUserObject = new pairedUserModel({
            primaryUserId: primaryUserId,
            secondaryUserId: secondaryUserId
        });

        pairedUserObject.save(function (err, pairedUserObject){
            if (err) {
                console.log(err);
                return console.error(err);
            } else {
                // Save successful
            }
        });
    }

    function checkIfPrimaryUserIsPaired(userId) {

        pairedUserModel.findOne({ primaryUserId: userId }, function(err, pairedUser) {
            if (err) {
                // handle error
                console.log(err);
                return;
            }

            if (pairedUser) {
                return true;
            } else {
                return false;
            }

        });
    }

    function checkIfSecondaryUserPaired(userId) {

        pairedUserModel.findOne({secondaryUserId:userId}, function(err, pairedUser) {

            if (err) {
                // handle error
                console.log(err);
                return;
            }

            if (pairedUser) {
                return true;
            } else {
                return false;
            }

        });

    }
}

function setupSchemas() {

    registrationSchema = mongoose.Schema({
        userId: String,
        deviceToken: String,
        deviceType: String
    });

    pairedUserSchema = mongoose.Schema({
        primaryUserId: String,
        secondaryUserId: String
    });

}

function setupModels() {

    registrationModel = mongoose.model(REGISTRATION_COLLECTION, registrationSchema);

}

function setupVirtuals() {

}