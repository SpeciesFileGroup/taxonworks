import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);
Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

const create = function(url, data) {
	return new Promise(function(resolve, reject) {
		Vue.http.post(url, data).then(response => {
			return resolve(response);
		}, response => {
			return reject(response);
		})
	});
}

const update = function(url, data) {
	return new Promise(function(resolve, reject) {	
		Vue.http.patch(url, data).then(response => {
			return resolve(response);
		}, response => {
			return reject(response);
		})
	});
}

const destroy = function(url, data) {
	return new Promise(function(resolve, reject) {	
		Vue.http.delete(url, data).then(response => {
			return resolve(response);
		}, response => {
			return reject(response);
		})
	});	
}

const getList = function(url) {
	return new Promise(function(resolve, reject) {	
		Vue.http.get(url).then(response => {
			return resolve(response);
		}, response => {
			return reject(response);
		})	
	});	
}

const vueCrud = {
	methods: {
		create: create,
		update: update,
		destroy: destroy,
		getList: getList,
	}
}

export default vueCrud