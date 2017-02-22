/*
Parameters: 

          mim: Minimum input length needed before make a search query
          url: Ajax url request
  placeholder: Input placeholder
        label: name of the propierty displayed on the list
  
  Example:
    <autocomplete 
      url="/contents/filter.json"
      param="hours_ago">
    </autocomplete>
*/

Vue.component('autocomplete', { 
    template: '<div class="vue-autocomplete"> \
                <input class="vue-autocomplete-input normal-input" type="text" v-on:input="update" v-model="type" /> \
                <ul v-show="showList"> \
                  <li v-for="(item, index) in json" :class="activeClass(index)" @mouseover="itemActive(index)" @click="itemClicked" @click.prevent="$emit(\'itemSelect\', item)"> \
                      <span> {{ item[label] }} </span> \
                  </li> \
                </ul> \
              </div>',

    data: function () {
      return {
        showList: false,
        type: "",
        json: [],
        current: -1
      };
    },

    props: {
      url: {
        type: String,
        required: true
      },

      label: String,

      min: {
        type: String,
        default: 1
      },

      limit: {
        type: String,
        default: ''
      }, 
      param: {
        type: String,
        default: "value"
      }       
    },
  
      methods: {
        clearResults: function() {
          this.json = [];
        },

        itemClicked function() {
          this.showList = false;
        },

        itemActive: function(index) {
          this.current = index;
        },        

        update: function() {
          if(this.type.length < Number(this.min)) return;
          
          var ajaxUrl = this.url + '?' + this.param + '=' + this.type;  

          this.clearResults();   

          this.$http.get(ajaxUrl).then(response => {
            this.json = response.body;
            this.showList = (this.json.length > 0)
            console.log(this.json);

          }, response => {
            // error callback
          });
        },
        activeClass: function activeClass(index) {
          return {
            active: this.current === index
          };
        },        
      }
    });