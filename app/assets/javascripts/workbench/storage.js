var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.storage = TW.workbench.storage || {};

Object.assign(TW.workbench.storage, {

	namespace: "TW",

	init: function() {
		var path = location.pathname.split("/"),
			concat = "";

		if(!isNaN(path[path.length-1])) {
			path.splice((path.length-1), 1);
		}
		path.forEach(function(item, index) {
			if(item != '')
				concat = concat + "::" + item;
  		});
  		this.namespace = concat;
	},

	changeNamespace: function(path) {
		this.namespace = path;
	},

	setItem: function(key, value) {
		var setKey = this.namespace + "::" + key;
		localStorage.setItem(setKey, value);
	},

	removeItem: function(key) {
		var setKey = this.namespace + "::" + key;
		localStorage.removeItem(setKey);
	},

	getItem: function(key, value) {
		var setKey = this.namespace + "::" + key;
		return localStorage.getItem(setKey);
	},

	newStorage: function() {
		return Object.assign({}, this);
	}
});