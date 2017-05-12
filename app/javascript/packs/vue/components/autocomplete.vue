/*
Parameters: 

          mim: Minimum input length needed before make a search query
         time: Minimum time needed after a key pressed to make a search query          
          url: Ajax url request
  placeholder: Input placeholder
        label: name of the propierty displayed on the list
   event-send: event name used to pass item selected
    autofocus: set autofocus

   :add-param: Send custom parameters
  
  Example:
    <autocomplete 
      url="/contents/filter.json"
      param="hours_ago">
    </autocomplete>
*/
<template>
  <div class="vue-autocomplete">
    <input class="vue-autocomplete-input normal-input" type="text" v-bind:placeholder="placeholder" v-on:input="checkTime" v-model="type" :autofocus="autofocus" v-bind:class="{'ui-autocomplete-loading' : spinner }"/>
    <ul v-show="showList" v-if="type && json.length">
      <li v-for="(item, index) in json" :class="activeClass(index)" @mouseover="itemActive(index)" @click.prevent="itemClicked(item[label]), sendItem(item)">
        <span v-html="item[label]"></span>
      </li>
    </ul>
  </div>
</template>

<script>
export default { 
    data: function () {
      return {
        spinner: false,
        showList: false,
        getRequest: 0,
        type: "",
        json: [],
        current: -1
      };
    },

    watch: {
      type: function() {
        if(this.type.length < Number(this.min)) {
          this.json = [];
        }
      }
    },

    props: {

      url: {
        type: String,
        required: true
      },

      autofocus: {
        type: Boolean,
        default: false
      },      

      label: String,

      time: {
        type: String,
        default: "500"
      },

      min: {
        type: String,
        default: 1
      },

      addParams: {
        type: Object
      },

      limit: {
        type: String,
        default: ''
      },   

      placeholder: {
        type: String,
        default: ''
      },             

      param: {
        type: String,
        default: "value"
      },

      eventSend: {
        type: String,
        default: "itemSelect"
      },            
    },
  
      methods: {
        sendItem: function(item) {
          this.$parent.$emit(this.eventSend, item);
        },

        clearResults: function() {
          this.json = [];
        },

        itemClicked: function(item) {
          this.type = item          
          this.showList = false;
        },

        itemActive: function(index) {
          this.current = index;
        },             

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

        update: function() {
          if(this.type.length < Number(this.min)) return;
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
            this.showList = (this.json.length > 0)
            this.spinner = false;
          }, response => {
            // error callback
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
    };
</script>