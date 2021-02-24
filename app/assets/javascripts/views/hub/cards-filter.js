var CarrouselData = function (sec, rows, columns) {

	// sec = Name of data section, this is for identify div.
	// rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls
	// columns = This is for the number of rows to be displayed
	
		this.children = 0,
		this.start = 1,
		this.maxRow = 0,
		this.maxColumn = 1,
		this.nro = 1,
		this.sectionTag = "",
		this.filters = {},
		this.isEmpty,
		this.maxRow = rows;
		this.sectionTag = sec;
		this.resetChildrenCount();
		if(this.maxRow >= this.children) {
			this.navigation(false);
		}
		this.handleEvents();
	};

	CarrouselData.prototype.handleEvents = function() {
		$('.data_card').mousedown(function(event) {
			if( event.target !== this) return;
			if((event.which) == 1) {
				location.href = $(this).children("a").attr('href');
			}
		});
	}

	CarrouselData.prototype.addFilter = function(nameFilter) {
		this.filters[nameFilter] = false;
	};

	CarrouselData.prototype.resetFilters = function() {
		this.filters = {};
		this.filterChildren();
	};

	CarrouselData.prototype.checkChildFilter = function(childTag) {
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

	CarrouselData.prototype.refresh = function() {
		this.filterChildren();
	}

	CarrouselData.prototype.resetChildrenCount = function() {
	  	this.children = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container ').length;
	};

	CarrouselData.prototype.empty = function() {
		return this.isEmpty;
	};

	CarrouselData.prototype.showEmptyLabel = function() {
		if(this.isEmpty) {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').show(250);
		}
		else {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').hide(250);
		}
	};

	CarrouselData.prototype.changeFilter = function(filterTag)	{
		this.filters[filterTag] = !this.filters[filterTag];
		this.filterChildren();
	};

	CarrouselData.prototype.setFilterStatus = function(filterTag, value)	{
		this.filters[filterTag] = value;
	};

	CarrouselData.prototype.filterKeys = function(handleKey) {
		for(var i = 0; i <= this.children; i++) {			
			child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(this.checkChildFilter(child.children().children(".filter_data"))) {
				if($(child).text().toLowerCase().indexOf(handleKey.toLowerCase()) > 0 || handleKey == "") {
					//child.show();
					child.removeClass('hide');
					child.attr("tabindex", 0);
				}
				else {
					child.removeAttr("tabindex");
					child.addClass('hide');
					//child.hide();
				}
			}
		}
		this.checkEmpty();
	}

	CarrouselData.prototype.checkEmpty = function() {
		var
			count = 0;

		for(var i = 0; i < this.children; i++) {			
			child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(!$(child).is(":visible")) {			
				count++;
			}
		}
		this.isEmpty = (count == this.children ? true : false);
		this.showEmptyLabel();
	}

	CarrouselData.prototype.filterChildren = function() {
		var
		find = 0;
		if(this.maxRow > this.children) {
			this.maxRow = this.children;
		}

		for (var i = 1; i <= this.maxRow; i++) {
			child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(this.checkChildFilter(child.children().children(".filter_data"))) {
				child.removeClass('hide');
				child.attr("tabindex", 0);
				find++;
			}
			else {
				child.removeAttr("tabindex");
				child.addClass('hide');
			}
		}
		this.isEmpty = (find <= 0);
		this.showEmptyLabel();
	};

	CarrouselData.prototype.navigation = function(value) {
		if(value) {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","show");
		}
		else {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","none");
		}
	};


	CarrouselData.prototype.loadingUp = function() {
    var
    rows = this.maxRow,
    posNro = this.nro,
		tag = this.sectionTag;

		if(this.nro > this.start) {
			$('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows-1) +')').addClass('hide')
			$('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro-1) +')').removeClass('hide');
			if(this.nro > this.start) {
				this.nro--;
			}        
		}  
	};

    CarrouselData.prototype.loadingDown = function() {
			var
				rows = this.maxRow,
				posNro = this.nro,
				tag = this.sectionTag;

			if((this.nro+this.maxRow) <= this.children) {
				$('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ posNro +')' ).addClass('hide');
				$('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows) +')' ).removeClass('hide');
			}

			if(this.nro < this.children) {
				this.nro++;
			}           
		};