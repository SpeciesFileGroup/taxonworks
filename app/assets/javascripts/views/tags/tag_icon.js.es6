var TW = TW || {};
TW.views = TW.views || {};
TW.views.tags = TW.views.tags || {};
TW.views.tags.tag_icon = TW.views.tags.tag_icon || {};

Object.assign(TW.views.tags.tag_icon, {

	init: function() {

		var that = this;

		$(document).on('pinboard:insert', function() {
			that.findTagIcon();
		});
		
		this.findTagIcon();
		$('.default_tag_widget').on('click', function() {
			console.log("1234");
			if(!$(this).hasClass('btn-disabled')) {
				if($(this).hasClass('btn-tag-add')) {
					that.createTag($(this).attr('data-tag-object-global-id'), that.getDefault()).then(response => {
						TW.workbench.alert.create('Tag was successfully updated.', 'notice')
						that.setAsDelete(this, response.id);
					});
				}
				else {
					if($(this).attr('data-tag-id')) {
						that.deleteTag($(this).attr('data-tag-object-global-id'), $(this).attr('data-tag-id')).then(response => {
							TW.workbench.alert.create('Tag was successfully removed.','notice')
							that.setAsCreate(this);
						});
					}
				}
			}
		});
	},

	findTagIcon: function() {
		var that = this;
		$('.default_tag_widget').each(function() {
			that.checkExist(this);
		});
	},

	makeAjaxCall: function(type, url, data) {
		return new Promise(function(resolve, reject) {
			$('body').mx_spinner();
			$.ajax({
			    url: url,
			    type: type,
			    data: data,
			    dataType: 'json',
			    success: function(data) {
			        return resolve(data);
			    },
			    complete: function() {
			    	$('body').mx_spinner('hide');
			    }
			});
		});
	},

	createTag: function(globalId, keyId) {
		var url = '/tags';
		var tag = {
			tag: {
				keyword_id: keyId,
				tag_object_global_entity: globalId
			}
		}
		return this.makeAjaxCall('POST', url, tag);
	},

	deleteTag: function(globalId, tagId) {
		
		var url = '/tags/' + tagId;
		var tag = {
			tag: {
				tag_object_global_entity: globalId,
				_destroy: true
			}
		}
		return this.makeAjaxCall('DELETE', url, tag);

	},

	setAsDelete: function(element, tagId) {
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-add');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-delete');
		$(element).attr('data-tag-id', tagId);
	},

	setAsCreate: function(element) {
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-delete');
		$(element).removeAttr('data-tag-id');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-add');
	},

	setAsDisable: function(element) {
		$(element).addClass('btn-tag-add');
		$(element).addClass('btn-disabled');
		$(element).removeAttr('data-tag-id');
	},

	checkExist: function(element) {
		var globalId = $(element).attr('data-tag-object-global-id');
		var defaultTag = this.getDefault();
		var that = this;
		if(defaultTag) {
			var url = "/tags/exists?global_id=" + globalId + "&keyword_id=" + defaultTag;

			$.get(url, function(data) {
				if(data) {
					console.log(data);
					that.setAsDelete(element,data.id);
				}
				else {
					that.setAsCreate(element);
				}
			});
		}
		else {
			this.setAsDisable(element);
		}
	},

	getDefault: function() {
		return $('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"]').attr('data-pinboard-object-id');
	}
});

$(document).on('turbolinks:load', function() {
  if ($(".default_tag_widget").length) {
    var tags_icon = TW.views.tags.tag_icon;
    tags_icon.init();
  }
});