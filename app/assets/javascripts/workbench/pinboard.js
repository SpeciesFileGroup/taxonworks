var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.pinboard = TW.workbench.pinboard || {};

Object.assign(TW.workbench.pinboard, {
	
    storage: undefined,

  	init: function () {
      var that = this;
      this.storage = TW.workbench.storage.newStorage();
      this.storage.changeNamespace("/workbench/pinboard");
      this.loadHeaderStatus();
      this.setDefaultClass();

      $('.slide-panel-category-header').on("click", function() {
        var element = $(this).parent().find('.slide-panel-category-content');
        var section = $(this).parent().find('.slide-panel-category-content').attr('data-pinboard-section');
        if(that.checkExpanded(section)) {
          that.storage.setItem(section, false)
        }
        else {
          that.storage.setItem(section, true)
        }
      });
      $(document).off('click', '[data-delete-all-pinboard]');
      $(document).on('click', '[data-delete-all-pinboard]', function() {
        that.cleanPinboardItems($(this).attr('data-delete-all-pinboard'));
      })
    },

    checkExpanded: function(section) {
      if(this.storage.getItem(section)) {
        return this.storage.getItem(section);
      }
      else {
        return false;
      }
    },

    cleanPinboardItems: function(klass) {
      var section = document.querySelector('[data-pinboard-section="' + klass + '"]');
      var elements = section.querySelectorAll('[data-method="delete"]');

      Array.prototype.forEach.call(elements, function(element) {
        element.click();
      });
    },

    setDefaultClass: function() {
      $('[data-panel-name="pinboard"] [data-insert]').each(function() {
        if($(this).attr('data-insert') == "true") {
          $(this).addClass('pinboard-default-item');
        }
        else {
          $(this).removeClass('pinboard-default-item');
        }
      });      
    },

    loadHeaderStatus: function() {
      var that = this;
      $('.slide-panel-category-header').each(function() {
        var element = $(this).parent().find('.slide-panel-category-content');
        var section = $(this).parent().find('.slide-panel-category-content').attr('data-pinboard-section');
        if(that.checkExpanded(section)) {
          $(element).toggle();
        }
      });
    },

    removeItem: function(id) {
      var element = $('[data-pinboard-item-id="' + id + '"]');
      var section = element.parent().attr('data-pinboard-section');
      $('[data-pinboard-item-id="' + id + '"]').remove();
      if (!$('[data-pinboard-section="' + section + '"] li').length) {
        var elementSection = document.getElementById('order_' + section);
        elementSection.parentNode.removeChild(elementSection);
      }
      this.eventPinboardRemove(id)
    },

    addToPinboard: function(object) {
      var injectItem = '<li class="slide-panel-category-item" data-insert="false" data-pinboard-object-id="' + object.pinned_object_id +'" data-pinboard-item-id="' + object.id + '" data-pin-item="' + object.id + '" id="order_' + object.id + '"> \
        <div class="handle flex-separate middle ui-sortable-handle"> \
          <a href="'+ object.pinned_object.object_url +'">\
            '+ object.pinned_object.object_tag +' \
          </a> \
        </div> \
        <div class="pinboard-dropdown"> \
          <div class="pinboard-menu-bar"></div> \
          <div class="pinboard-menu-bar"></div> \
          <div class="pinboard-menu-bar"></div> \
          <div class="itemOptions pinboard-dropdown-content"> \
            <a href="'+ object.object_url +'" class="remove circle-button button-delete" data-remote="true" rel="nofollow" data-method="delete">Remove</a>'
            if(object.pinned_object_type == "Document") { 
              injectItem = injectItem + '<a class="pdfviewerItem" data-pdfviewer="@pinboard_item.pinned_object.document_file(:original, false)">PDF Viewer</a>'
            } 
            injectItem = injectItem + '<a class="circle-button button-pinboard-default button-submit option-default" data-remote="true" rel="nofollow" data-method="put" href="/pinboard_items/'+ object.id +'?pinboard_item%5Bis_inserted%5D=true">Make default</a> \
          </div> \
        </div> \
      </li>'

      if (!$('[data-pinboard-section="'+ object.pinned_object_section +'"]').length) {
        this.createCategory(object.pinned_object_section)
      }

      $(injectItem).appendTo('[data-pinboard-section="'+ object.pinned_object_section +'"]');
      this.eventPinboardAdd(object);
    },

    createCategory: function(title) {
      var injectCategory = '<div id="order_'+ title +'s"> \
              <div class="slide-panel-category-header">'+ title +'s</div> \
                <ul class="slide-panel-category-content" \
                          data-pinboard-section="'+ title +'" \
                          data-sortable \
                          data-sortable-items="li" \
                          data-sortable-on-change-url="/pinboard_items/update_position" \
                        > \
            </ul> \
          </div>';

        $(injectCategory).appendTo('#pinboard');
    },

    eventPinboardRemove: function (id) {
      var event = new CustomEvent("pinboard:remove", {
        detail: {
          id: id,
        }
      });
      document.dispatchEvent(event);
    },

    eventPinboardAdd: function (object) {
      var event = new CustomEvent("pinboard:add", {
        detail: {
          id: object.id,
          type: object.pinned_object_type,
          object_id: object.pinned_object_id,
        }
      });
      document.dispatchEvent(event);
    }
});

$(document).on('turbolinks:load', function() {
	if($('[data-panel-name="pinboard"]').length) {
	    TW.workbench.pinboard.init();
	}	
});