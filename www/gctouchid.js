function GCTouchID() { }

GCTouchID.prototype.isAvailable = function (onSuccess, onFail) {
	cordova.exec(onSuccess, onFail, 'GCTouchID', 'isAvailable');
};

GCTouchID.prototype.authWithTouchID = function (onSuccess, onFail, data) {
	cordova.exec(onSuccess, onFail, 'GCTouchID', 'authWithTouchID', [data]);
};


GCTouchID.prototype.setPassword = function (onSuccess, onFail, data) {
	cordova.exec(onSuccess, onFail, 'GCTouchID', 'setPassword', [data]);
};

// Register the plugin
var gctouchid = new GCTouchID();
module.exports = gctouchid;