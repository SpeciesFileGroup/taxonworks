var TW = TW || {};
TW.views = TW.views || {};
TW.views.annotations = TW.views.annotations || {};


Object.assign(TW.views.annotations, {

	init: function() {
		var annotations = [];
		var that = this;
		var metadata = undefined;

		$(document).off('annotator:close');
		$(document).on('annotator:close', function(event) {
			var metadata = event.detail.metadata;
			var annotationDOMElement = document.querySelector(`[data-annotator-list-object-id="${metadata.object_id}"]`);

			if(annotationDOMElement) {
				annotations = that.getAnnotationOptions(metadata.url, Object.keys(metadata.annotation_types));
				that.getLists(annotations).then(response => {
					that.createAllLists(response, annotationDOMElement);
				});
			}
		});
	},

	getAnnotationOptions: function(url, annotations) {
		var list = []

		annotations.forEach(function(element) {
			list.push({
				label: element,
				url: `${url}/${element}.json`,
				list: []
			})
		});
		return list;
	},

	getLists: function(annotations) {
		var that = this;

		return new Promise(function(resolve,reject) {
			var list = [];

			annotations.forEach(function(element) {
				list.push(that.makeAjaxCall('get', element.url))
			})

			Promise.all(list).then(values => { 
				annotations.forEach(function(element, index) {
					annotations[index].list = values[index];
				})
			  	return resolve(annotations);
			});
		});
	},

	createAllLists: function(objectList, annotationDOMElement) {
		var that = this;
		var completeList = document.createElement('div');

		objectList.forEach(function(element) {
			if(element.list.length) {
				var title = document.createElement('h3');
			
				title.classList.add('capitalize');
				title.innerHTML = element.label;

				completeList.appendChild(title);
				completeList.appendChild(that.createAnnotatorList(element));
			}
		});

		annotationDOMElement.innerHTML = '';
		annotationDOMElement.appendChild(completeList);		
	},

	createAnnotatorList: function(annotatorList) {
		var list = document.createElement('ul');

		annotatorList.list.forEach(function(element) {
			var li = document.createElement('li');
			li.innerHTML = element.object_tag;
			list.appendChild(li);
		});

		return list;
	},

	makeAjaxCall: function(type, url, data) {
		return new Promise(function(resolve, reject) {
			$.ajax({
			    url: url,
			    type: type,
			    data: data,
			    dataType: 'json',
			    success: function(data) {
			        return resolve(data);
			    },
			    complete: function() {
			    	return resolve([]);
			    }
			});
		});
	},
});

$(document).on('turbolinks:load', function() {
  if($(".annotations_summary_list").length) {
  	TW.views.annotations.init();
  }
});