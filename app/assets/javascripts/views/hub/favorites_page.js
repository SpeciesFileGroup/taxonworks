$(document).ready(function() {
	if($('#favorite-page').length) {
		var 
		favoritesTask = new CarrouselTask("#task_carrousel",10,1);
		favoritesTask.filterChilds();
		favoritesTask.resetView();
    	favoritesTask.filterChilds();
    	favoritesTask.showChilds();   
    	favoritesData = new CarrouselData("Favorites-Task",10,2);
		favoritesData = new CarrouselData("Favorites-Data",10,1);
		favoritesData.filterChilds();
		$('.data_card').mousedown(function(event) {
			if((event.which) == 1) {
				location.href = $(this).children("a").attr('href');
			}
		}); 



		[favoritesTask, favoritesData].forEach(function(element) {
			element.addFilter("data-category-collecting_event");
			element.addFilter("data-category-Taxon_name");
			element.addFilter("data-category-source");
			element.addFilter("data-category-collection_object");
			element.addFilter("data-category-biology");
			element.filterChilds();

		});

		function resetFilters() {
			[favoritesTask, favoritesData].forEach(function(element) {
				element.resetFilters();
			});
		}

		$('.data_card').mousedown(function(event) {
			if((event.which) == 1) {
				location.href = $(this).children("a").attr('href');
			}
		});    

		$('#filter [data-filter-category]').on('click', function() {
			var
			elementFilter = $(this).attr('data-filter-category');
			if(elementFilter === "reset") {
				resetFilters();
			}
			else {
				[favoritesTask, favoritesData].forEach(function(element) {
					element.changeFilter("data-category-"+ elementFilter);				
				});
			}
		});  



	}
});
