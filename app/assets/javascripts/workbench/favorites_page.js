$(document).ready(function() {
  if($('[data-current-tab="favorite"]').length) {
	var 
	favoritesTask = new carrouselTask("Favorites-Task",3,1);
	favoritesTaskPanel = new carrouselData("Favorites-Task",1,2);
	favoritesData = new carrouselData("Favorites-Data",99,2);
	favoritesData.filterChilds();

	 $('.data_card').mousedown(function(event) {
	  	if((event.which) == 1) {
	    	location.href = $(this).children("a").attr('href');
		}
	  }); 
	 }
});
