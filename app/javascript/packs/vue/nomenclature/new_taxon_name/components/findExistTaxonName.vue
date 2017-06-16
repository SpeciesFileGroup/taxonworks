<template>
	<div>
		<ul v-if="json.length > 0">
			<li v-for="item in json"><a @click="sendItem(item)" v-html="item[label]"></a></li>
		</ul>
		<p v-else>No existing matches</p>
	</div>
</template>

<script>
export default {
	props: { 
		url: {
			type: String,
			required: true
		}, 
		search: {
			type: String,
			required: true
		},
		label: {
			type: String
		},
	    time: {
	        type: String,
	        default: "500"
	    },
	    addParams: {
	        type: Object
	    },
	    param: {
	        type: String,
	        default: "value"
	    },
	},
	data: {
		json: [],
		spinner: false
	},
	watch: {
		search: function(val) {
			this.update(val);
		}
	},
	methods: {
        ajaxUrl: function() {
          var tempUrl = this.url + '?' + this.param + '=' + this.type; 
          var params = '';
          if(this.addParams) {
            Object.keys(this.addParams).forEach((key) => {
              params += `&${key}=${this.addParams[key]}`
            })
          }   
          return tempUrl + params;           
        },
        checkTime: function() {
          var that = this;
          if(this.getRequest) {
            clearTimeout(this.getRequest);
          }   
          this.getRequest = setTimeout( function() {    
            that.update();  
          }, that.time);           
        }, 
        sendItem: function(item) {
        	this.$emit('getItem', item);
        },
        update: function() {
          	if(this.search.length < Number(this.min)) return;
          	this.spinner = true;
          	this.clearResults();   
          	this.$http.get(this.ajaxUrl(), {
            	before(request) {
                	if (this.previousRequest) {
                		this.previousRequest.abort();
                	}
                	this.previousRequest = request;
            	}            
            }).then(response => {
            	this.json = response.body;
            	this.spinner = false;
            }, response => {
            	this.spinner = false;
            });
        },
        activeClass: function activeClass(index) {
          return {
            active: this.current === index
          };
        },   
        activeSpinner: function() {
          return 'ui-autocomplete-loading'
        },  
	}
}
</script>