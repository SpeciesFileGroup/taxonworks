$(document).ready(function() {
  if($("#data_cards").length) {
    initDataCardsPage();
  }
});

function initDataCardsPage() {

var 
	favorites = new carrouselData("Favorites",99,4),	
	core = new carrouselData("Core",99,1),	
	supporting = new carrouselData("Supporting",99,2),	
	annotations = new carrouselData("Annotations",99,1);

favorites.addFilter("data-category-collectingevent");
favorites.addFilter("data-category-TaxonName");
favorites.addFilter("data-category-Source");
favorites.addFilter("data-category-collectionobject");
favorites.filterChilds();

core.addFilter("data-category-collectingevent");
core.addFilter("data-category-TaxonName");
core.addFilter("data-category-Source");
core.addFilter("data-category-collectionobject");
core.filterChilds();

supporting.addFilter("data-category-collectingevent");
supporting.addFilter("data-category-TaxonName");
supporting.addFilter("data-category-Source");
supporting.addFilter("data-category-collectionobject");
supporting.filterChilds();

annotations.addFilter("data-category-collectingevent");
annotations.addFilter("data-category-TaxonName");
annotations.addFilter("data-category-Source");
annotations.addFilter("data-category-collectionobject");
annotations.filterChilds();

function changeAllSectionsFilter(dataTag, value) {
	core.setFilterStatus(dataTag,value);
  	supporting.setFilterStatus(dataTag,value);
  	annotations.setFilterStatus(dataTag,value);
}


  //Getting clicks on arrows
  $('.data_section[data-section="Core"]').on('click', 'a.cards-down', function() {
    core.loadingDown();
  });

  $('.data_section[data-section="Core"]').on('click', 'a.cards-up', function() {
    core.loadingUp();
  }); 

  $('.data_section[data-section="Supporting"]').on('click', 'a.cards-down', function() {
    supporting.loadingDown();
  });

  $('.data_section[data-section="Supporting"]').on('click', 'a.cards-up', function() {
    supporting.loadingUp();
  }); 

  $('.data_section[data-section="Annotations"]').on('click', 'a.cards-down', function() {
    annotations.loadingDown();
  });

  $('.data_section[data-section="Annotations"]').on('click', 'a.cards-up', function() {
    annotations.loadingUp();
  });      


  $('.data_card').mousedown(function(event) {
  	if((event.which) == 1) {
    	location.href = $(this).children("a").attr('href');
	}
  });     

  $('#filter [data-filter-category="taxon_name"]').on('click', function() {
      	core.changeFilter("data-category-TaxonName");
      	supporting.changeFilter("data-category-TaxonName");
      	annotations.changeFilter("data-category-TaxonName");
      	favorites.changeFilter("data-category-TaxonName"); 
  });  

  $('#filter [data-filter-category="collecting_event"]').on('click', function() {
      	core.changeFilter("data-category-collectingevent"); 
      	supporting.changeFilter("data-category-collectingevent"); 
      	annotations.changeFilter("data-category-collectingevent"); 
      	favorites.changeFilter("data-category-collectingevent");
  });

  $('#filter [data-filter-category="collection_object"]').on('click', function() {
	    core.changeFilter("data-category-collectionobject");   
	    supporting.changeFilter("data-category-collectionobject");   
	    annotations.changeFilter("data-category-collectionobject"); 
	    favorites.changeFilter("data-category-collectionobject");
  });  

  $('#filter [data-filter-category="source"]').on('click', function() {  	
      	core.changeFilter("data-category-Source");
      	supporting.changeFilter("data-category-Source");
      	annotations.changeFilter("data-category-Source");
      	favorites.changeFilter("data-category-Source");
  });


  $('#filter [data-filter-category="reset"]').on('click', function() {
		changeAllSectionsFilter("data-category-Source", false);
		changeAllSectionsFilter("data-category-TaxonName", false);
		changeAllSectionsFilter("data-category-collectionobject", false);
		changeAllSectionsFilter("data-category-collectingevent", false);
  });  

$('.data_card div[data-category-collectingevent="true"]').append("<img src='/assets/icons/geo_location.svg'/>");
$('.data_card div[data-category-TaxonName="true"]').append("<img src='/assets/icons/new.svg'/>");
$('.data_card div[data-category-collectionobject="true"]').append("<img src='/assets/icons/picking.svg'/>");
$('.data_card div[data-category-Source="true"]').append("<img src='/assets/icons/book.svg'/>");   
   
}