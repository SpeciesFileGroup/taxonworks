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
});

$(document).on('turbolinks:load', function() {
	if($('[data-panel-name="pinboard"]').length) {
	    TW.workbench.pinboard.init();
	}	
});