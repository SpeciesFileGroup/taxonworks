

class filterHub {

	constructor() {
		var
		arrayData = [],
		that = this,
		arrayTasks = [];

		$("[data-section]").each(function(i, element) {
		    arrayData.push(new CarrouselData($(element).attr("data-section"),99,0));
		});

		$('#filter [data-filter-category]').on('click', function() {
		    var
		    	elementFilter = $(this).attr('data-filter-category');

		    if(elementFilter === "reset") {
		    	that.changeAllSectionsFilter(arrayData);
		    }
		    else {
		    	arrayData.forEach(function(element) {
		    		element.changeFilter("data-category-"+ elementFilter);
		    	});
		    }
		    if(that.allEmpty(arrayData)) {
		    	$('[data-section="Supporting"] .reset-all-filters').fadeIn();
		    }
		    else {
		    	$('.reset-all-filters').fadeOut(0);
		    }    
		});		
	}

	changeAllSectionsFilter(arrayData) {
	    arrayData.forEach(function(element) {
	    	element.resetFilters();
	    	element.filterChilds();
	    	$('.reset-all-filters').fadeOut(0);
	    });
	}	

	allEmpty(arraySection) {
		let inc = 0;

		arraySection.forEach(function (element) {
			if(element.empty()) {
				inc++
			}
		});
		return (inc == arraySection.length);
	}
}

class CarrouselData {

	constructor(sec, rows, columns) {

	// sec = Name of data section, this is for identify div.
	// rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls
	// columns = This is for the number of rows to be displayed
	
		this.childs = 0,
		this.start = 1,
		this.maxRow = 0,
		this.maxColumn = 1,
		this.nro = 1,
		this.sectionTag = "",
		this.filters = {},
		this.isEmpty,
		this.maxRow = rows;
		this.sectionTag = sec;
		this.resetChildsCount();
		if(this.maxRow >= this.childs) {
			this.navigation(false);
		}

		this.handleEvents();
	};

	handleEvents() {

	}

	addFilter(nameFilter) {
		this.filters[nameFilter] = false;
	};

	resetFilters() {
		this.filters = {};
		this.filterChilds();
	};


	checkChildFilter(childTag) {
		var find = 0;
		var isTrue = 0;
		for (var key in this.filters) {
			if(this.filters[key] == true) {
				find++;
				if ($(childTag).attr(key)) {
					isTrue++;
				}
		    }	
		}
		if(isTrue == find) {
			return true;
		}
		else {
			return false;
		}		
	};

	resetChildsCount() {
	  	this.childs = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container ').length;
	};

	empty() {
		return this.isEmpty;
	};

	showEmptyLabel() {
		if(this.isEmpty) {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').show(250);
		}
		else {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').hide(250);
		}
	};

	changeFilter(filterTag)	{
		this.filters[filterTag] = !this.filters[filterTag];
		this.filterChilds();
	};

	setFilterStatus(filterTag, value)	{
		this.filters[filterTag] = value;
	};

	filterKeys(handleKey) {
		for(var i = 0; i <= this.childs; i++) {			
			let child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(this.checkChildFilter(child.children().children(".filter_data"))) {
				if($(child).text().toLowerCase().indexOf(handleKey.toLowerCase()) > 0 || handleKey == "") {
					child.show();
				}
				else {
					child.hide();
				}
			}
		}
		this.checkEmpty();
	}

	checkEmpty() {
		var
			count = 0;

		for(var i = 0; i < this.childs; i++) {			
			child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(!$(child).is(":visible")) {			
				count++;
			}
		}
		this.isEmpty = (count == this.childs ? true : false);
		this.showEmptyLabel();
	}

	filterChilds() {
		var
		find = 0;
		if(this.maxRow > this.childs) {
			this.maxRow = this.childs;
		}

		for (var i = 1; i <= this.maxRow; i++) {
			let child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(this.checkChildFilter(child.children().children(".filter_data"))) {
				child.show(250);
				find++;
			}
			else {
				child.hide(250);
			}
		}
		this.isEmpty = (find <= 0);
		this.showEmptyLabel();
	};

	navigation(value) {
		if(value) {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","show");
		}
		else {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","none");
		}
	};


	loadingUp() {
    	var
    	  rows = this.maxRow,
    	  posNro = this.nro,
    	  tag = this.sectionTag;

	    if(this.nro > this.start) {
	        $('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows-1) +')').hide(100, function() {
	  	        $('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro-1) +')').show(150)
	        });      
	        if(this.nro > this.start) {
	        	this.nro--;
	      	}        
	    }  
	};

    loadingDown() {
    	var
    	  rows = this.maxRow,
    	  posNro = this.nro,
    	  tag = this.sectionTag;

	    if((this.nro+this.maxRow) <= this.childs) {
	        $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ posNro +')' ).hide(100, function() {
	        	
	        	$('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows) +')' ).show(150)

	        });   
	        if(this.nro < this.childs) {
	        	this.nro++;
	      	}          
    	} 
  	};
  }
$(document).ready(function() {
	  if($("#data_cards").length) {
var prueba = new filterHub();
}
});