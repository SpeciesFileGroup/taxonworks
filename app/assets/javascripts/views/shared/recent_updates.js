var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.recent_updates = TW.views.shared.recent_updates || {};

Object.assign(TW.views.shared.recent_updates, {

	init: function() {
		$(".recent_updates li").dblclick(function() {
		  location.href = $(this).find("a").attr("href");
		});
		
		this.opacityUpdates();
		$(document).ready(recentUpdatesContextMenu);
		$(document).on('page:change', recentUpdatesContextMenu);

		function recentUpdatesContextMenu() {
		  	$.contextMenu('destroy', ".recent_updates li" );
		    $.contextMenu({
	          selector: '.recent_updates li', 
		      autoHide: true,
		      callback: function(key, options) {
	            var m = "clicked: " + key;
		          switch(key) {
		            case "show":
		            	location.href = $(this).children("a:nth-child(1)").attr('href');
		          	break;
		            case "edit":
		            	location.href = $(this).children("a:nth-child(2)").attr('href');
	              	break;                  
		          }
		      },
		      items: {
		        "show": {name: "Show", icon: "show"},
		        "sep1": "---------",
		        "edit": {name: "Edit", icon: "edit"},
		      }
		    });
		}
	},

	opacityUpdates: function() {
		var childs = $(".recent_updates ul").children().length,
			opacityValue = 1;

		for(var i = 1; i <= childs; i++) {
			$(".recent_updates li:nth-child("+(i)+")").css("opacity", (opacityValue-(i*0.1)));
		}
	}	
});

$(document).ready(function() {
  if($("#model_index").length) {
    var init_recent_updates = TW.views.shared.recent_updates;
    init_recent_updates.init();
  }
});
