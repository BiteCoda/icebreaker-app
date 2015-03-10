var DATABASE_NAME = 'icebreakers';
var MONGO_URL = 'mongodb://localhost/' + DATABASE_NAME;
var mongoose;

// Collection names
var REGISTRATION_COLLECTION = 'REGISTRATION_COLLECTION'
var PAIRED_USER_COLLECTION = 'PAIRED_USER_COLLECTION'
var AUTHENTICATION_COLLECTION = 'AUTHENTICATION_COLLECTION'

// Schemas
var authenticationSchema;
var registrationSchema;
var pairedUserSchema;

// Models
var authenticationModel;
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

    },

    /*
    *   Authentication Model functions
    */
    
    getAuthenticationObjectByUserId: function(userId) {
    
    
    },
    
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

    },
    
    getDeviceTokenByUserId: function(userId) {
        
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
    },

    /*
    *   PairedUser Model functions
    */
    
    createPairedUserObject: function(primaryUserId, secondaryUserId) {
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
    },

    checkIfPrimaryUserIsPaired: function(userId) {
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
    
    },
    
    checkIfSecondaryUserIsPaired(userId) {
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

    authenticationSchema = mongoose.Schema({
        userId: String,
        password: String
    });
    
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

    authenticationModel = mongoose.model(AUTHENTICATION_COLLECTION, authenticationSchema);
    registrationModel = mongoose.model(REGISTRATION_COLLECTION, registrationSchema);
    pairedUserModel = mongoose.model(PAIRED_USER_COLLECTION, pairedUserSchema);

}

function setupVirtuals() {
    
    authenticationSchema
    .virtual('authenticate')
    .get(function (password) {
        if (password == this.password) {
            return true;
        } else {
            return false;
        }
    });

}