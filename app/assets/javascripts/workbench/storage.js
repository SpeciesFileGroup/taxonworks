var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.storage = TW.workbench.storage || {};

Object.assign(TW.workbench.storage, {

	namespace: null,

	init: function() {
		
  		this.namespace = this.splitNamespace(location.pathname);
	},

	splitNamespace: function(newNamespace) {
		var path = newNamespace.split("/");
		var concat = "";
		if(!isNaN(path[path.length-1])) {
			path.splice((path.length-1), 1);
		}
		path.forEach(function(item, index) {
			if(item != '')
				concat = concat + "::" + item;
  		});		
		return "TW" + concat;
	},

	changeNamespace: function(path) {
		this.namespace = this.splitNamespace(path);
	},

	getNamespace: function() {
		return this.namespace;
	},

	setItem: function(key, value) {
		var setKey = this.namespace + "::" + key;
		localStorage.setItem(setKey, JSON.stringify(value));
	},

	removeItem: function(key) {
		var setKey = this.namespace + "::" + key;
		localStorage.removeItem(setKey);
	},

	getItem: function(key, value) {
		var setKey = this.namespace + "::" + key;
		return JSON.parse(localStorage.getItem(setKey));
	},

	newStorage: function() {
		return Object.assign({}, this);
	}
});