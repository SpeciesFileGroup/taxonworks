 //Task page

 $('#task_carrousel div.source').replaceWith('<div class="categories source"><img src="/assets/icons/book.svg" width="15"/></div>');
 $('#task_carrousel div.collecting_event').replaceWith('<div class="categories collecting_event"><div><img src="/assets/icons/geo_location.svg" alt="Collection object" width="15"/></div>');
 $('#task_carrousel div.collection_object').replaceWith('<div class="categories collection_object"><img src="/assets/icons/picking.svg" width="15"/></div>');



//Hub Filter
$('#filter [data-filter-category="taxon_name"]').prepend('<img src="/assets/icons/new.svg"/>');
$('#filter [data-filter-category="source"]').prepend('<img src="/assets/icons/book.svg"/>');
$('#filter [data-filter-category="collection_object"]').prepend('<img src="/assets/icons/picking.svg"/>');
$('#filter [data-filter-category="collecting_event"]').prepend('<img src="/assets/icons/geo_location.svg"/>');	