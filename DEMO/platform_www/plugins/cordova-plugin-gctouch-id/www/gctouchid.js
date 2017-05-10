cordova.define("cordova-plugin-gctouch-id.GCTouchID", function(require, exports, module) {
var cordova = require('cordova');

function GCTouchID() { }

GCTouchID.prototype.isAvaible = function (onSuccess, onFail) {
	cordova.exec(onSuccess, onFail, 'GCTouchID', 'isAvaible');
};

// Register the plugin
var gcnsusersdefaults = new GCNSUsersDefaults();
module.exports = gcnsusersdefaults;

});
