import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

const create = function(url, data) {
	return Vue.$http.post(url, data).then(response => {
		return response;
	}, response => {
		return response;
	})
}

const update = function(url, data) {
	return Vue.$http.patch(url, data).then(response => {
		return response;
	}, response => {
		return response;
	})	
}

const destroy = function(url, data) {
	return Vue.$http.delete(url, data).then(response => {
		return response;
	}, response => {
		return response;
	})	
}

const getList = function(url, data) {
	return Vue.$http.get(url).then(response => {
		return response;
	}, response => {
		return response;
	})	
}

const vueCrud = {
	methods: {
		create: create,
		update: update,
		destroy: destroy,
		getList: getList
	}
}

export default {
	vueCrud
}