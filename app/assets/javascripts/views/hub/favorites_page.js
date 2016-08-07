$(document).ready(function() {
	if($('#favorite-page').length) {
		var 
		favoritesTask = new CarrouselTask("#task_carrousel",99,1);
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

		function resetFilters() {
			[favoritesTask, favoritesData].forEach(function(element) {
				element.resetFilters();
				$('.reset-all-filters').fadeOut(0);
			});
		}

		$('.data_card').mousedown(function(event) {
			if((event.which) == 1) {
				location.href = $(this).children("a").attr('href');
			}
		});   

		function resetStatusFilter(element) {
			element.setFilterStatus("data-category-prototype",false);
			element.setFilterStatus("data-category-unknown",false);
			element.setFilterStatus("data-category-stable",false);
			element.setFilterStatus("data-category-complete",false);                  
		}

		$('#filter .filter-category [data-filter-category]').on('click', function() {
			if(!$(this).hasClass("activated")) {
				resetStatusFilter(favoritesData);
				resetStatusFilter(favoritesTask);
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

				if(favoritesTask.empty() && favoritesData.empty()) {
					$('.reset-all-filters').fadeIn();
				}
				else {
					$('.reset-all-filters').fadeOut(0);
				}
			}
		});  

		$('.reset-all-filters').on('click', function() {
			resetFilters();	
		});

	}
});
