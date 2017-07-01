<template>
	<div>
    <div v-if="spinner" class="spinner">
      <div class="box-spinner"></div>
    </div>
    <h4 v-if="search && json.length == 0">No existing matches</h4>
		<ul v-if="json.length > 0">
			<li v-for="item, index in json" v-if="index < maxResults"><a @click="sendItem(item)" v-html="item[label]"></a></li>
		</ul>
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
  			required: true
  		},
  		label: {
  			type: String
  		},
  	  time: {
        type: String,
        default: "500"
      },
      maxResults: {
        type: Number,
        default: 10,
      },
      addParams: {
        type: Object
      },
      param: {
        type: String,
        default: "value"
      },
  	},
  	data: function() {
      return {
  		  json: [],
    		spinner: false,
        getRequest: 0
      }
  	},
  	watch: {
  		search: function(val) {
        if(val != undefined) {
  			  this.checkTime();
        }
  		}
  	},
  	methods: {
      ajaxUrl: function() {
        var tempUrl = this.url + '?' + this.param + '=' + this.search; 
        var params = '';
        if(this.addParams) {
          Object.keys(this.addParams).forEach((key) => {
            params += `&${key}=${this.addParams[key]}`
          })
        }   
        return tempUrl + params;           
      },
      sendItem: function(item) {
      	this.$emit('getItem', item);
      },
      clearResults: function() {
        this.json = [];
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
            console.log(this.json);
          	this.spinner = false;
          }, response => {
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