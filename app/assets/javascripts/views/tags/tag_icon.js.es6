var TW = TW || {};
TW.views = TW.views || {};
TW.views.tags = TW.views.tags || {};
TW.views.tags.tag_icon = TW.views.tags.tag_icon || {};

Object.assign(TW.views.tags.tag_icon, {

	objectElement: undefined,
	CTVCount: 0,
	toolTip: undefined,

	init: function(element) {

		var that = this;
		this.objectElement = element;
		this.checkExist(this.objectElement);
		$(document).on('pinboard:insert', function() {
			that.checkExist(that.objectElement);			
		});

		$(element).on('click', function() {
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

	createTooltip: function(element) {
		if(this.toolTip && this.toolTip.getReferenceData(element || this.toolTip.getPopperElement(this.objectElement))) {
			this.toolTip.update(this.toolTip.getPopperElement(this.objectElement))
		}
		else {
			this.toolTip = tippy(element, {
				position: 'bottom',
				animation: 'scale',
				inertia: true,
				size: 'small',
				arrowSize: 'small',
				arrow: true
			})
		}

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

	createCountLabel: function() {
		return '<p>Used already on '+ this.CTVCount +' objects</p>';
	},

	setAsDelete: function(element, tagId) {
		$(element).attr('title', 'Remove ' + this.getDefaultString() + ' tag ' + this.createCountLabel());
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-add');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-delete');
		$(element).attr('data-tag-id', tagId);
		this.createTooltip(element);
	},

	setAsCreate: function(element) {
		$(element).attr('title', 'Create tag: ' + this.getDefaultString() + this.createCountLabel());
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-delete');
		$(element).removeAttr('data-tag-id');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-add');
		this.createTooltip(element);
	},

	setAsDisable: function(element) {
		$(element).attr('title', 'Select a default CVT first.');
		$(element).addClass('btn-tag-add');
		$(element).addClass('btn-disabled');
		$(element).removeAttr('data-tag-id');
		this.createTooltip(element);
	},

	getCVTCount: function(id) {
		var that = this;
		return this.makeAjaxCall('GET', '/controlled_vocabulary_terms/'+ id, '').then(response => {
			return response.tag_count;
		});
	},

	checkExist: function(element) {
		var globalId = $(element).attr('data-tag-object-global-id');
		var defaultTag = this.getDefault();
		var that = this;
		if(defaultTag) {
			var url = "/tags/exists?global_id=" + globalId + "&keyword_id=" + defaultTag;

			this.getCVTCount(defaultTag).then(response => {
				that.CTVCount = response;
				$.get(url, function(data) {
					if(data) {
						that.setAsDelete(element, data.id);
					}
					else {
						that.setAsCreate(element);
					}				
				});
			});
		}
		else {
			this.setAsDisable(element);
		}
	},
	getDefaultString: function() {
		return $('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"] a')[0].textContent;
	},

	getDefault: function() {
		return $('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"]').attr('data-pinboard-object-id');
	}
});

$(document).on('turbolinks:load', function() {
  $(".default_tag_widget").each(function() {
  	TW.views.tags.tag_icon.init(this);
  })
});