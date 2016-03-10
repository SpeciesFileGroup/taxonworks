$(document).ready(function() {
  if($("#model_index").length) {
    modelIndexJS();
  }
});


function opacityUpdates() {
	var childs = $(".recent_updates ul").children().length,
		opacityValue = 1,
		opacityResult;

	if((childs/10) == 1) {
		opacityResult = 0.1;
	} 
	else {
		opacityResult = childs/10;
	};
	for(i = 1; i <= childs; i++) {
		$(".recent_updates li:nth-child("+(i)+")").css("opacity", opacityValue);
		opacityValue -= opacityResult;
	}
}


function modelIndexJS() {
	$(".recent_updates li").dblclick(function() {
	  location.href = $(this).find("a").attr("href");
	});

	
opacityUpdates();
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
}
