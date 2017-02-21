/*
Parameters: 

          mim: Minimum input length needed before make a search query
          url: ajax url request
  placeholder: input placeholder
  
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
                  <li v-for="(item, index) in json" :class="activeClass(index)" @mouseover="itemActive(index)" @click="itemSelected(index)"> \
                    <span v-text="item.text"></span> \
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
      min: {
        type: Number,
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

        itemSelected: function(index) {
          console.log(index)
          this.showList = false;
          this.current = index;
        },

        itemActive: function(index) {
          this.current = index;
        },        

        update: function() {
          if(this.type.length > this.min) return;
          
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