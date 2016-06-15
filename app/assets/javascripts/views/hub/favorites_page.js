$(document).ready(function() {
  if($('#favorite-page').length) {
	var 
	favoritesTask = new CarrouselTask("Favorites-Task",8,1);
	favoritesTask.filterChilds();
	favoritesTaskPanel = new CarrouselData("Favorites-Task",1,2);
	favoritesData = new CarrouselData("Favorites-Data",99,1);
	favoritesData.filterChilds();
	 $('.data_card').mousedown(function(event) {
	  	if((event.which) == 1) {
	    	location.href = $(this).children("a").attr('href');
		}
	  }); 
	 }
});
