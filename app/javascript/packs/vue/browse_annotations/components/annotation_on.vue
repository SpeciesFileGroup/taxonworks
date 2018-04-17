<template>
  <div>
    <ul>
      <li v-for="label, key in list" >
        <label @click="selectModel(key)">
          <input
            name="model"
            type="checkbox"
            :value="key">
          <span
            class="new-combination-rank-list-taxon-name"
            v-html="label"/>
        </label>
      </li>
    </ul>
  <!--<span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>-->
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String
    },
    usedOn: {
      type: Array
    },
    annotationType: {
      type: Object,
      required: true
    }
  },

  watch: {
    value(newVal) {
      this.getResult(newVal);
    },
    annotationType: {
      handler(newVal) {
        if (newVal) {
          // Here is where you trigger the method to populate the smart selector
          // you will take the values of type and used_on from annotationType object.
          // annotationType.type
          // aanotationType.used_on
          // var myVal = newVal.usedOn;
          // var myList = {};
          
          // myVal.forEach(function(val) {
          //   myList[myVal.type] = myVal.usedOn;
          // });
          for (let i = 0; i<newVal.used_on.count; i++) {
            this.list[newVal.type[i]] = newVal.used_on[i];
          }
          // newVal.used_on.forEach( function(used) {
          //   this.list[used] = used;
          // })
          // this.list = newVal.usedOn;
          // this.smartSelector = newVal.select_options_url;
        }
      }
    }
  },
  data() {
    return {
      list: {},
      result: undefined
    };
  },
  // mounted: function () {
  //   this.$http.get('/tasks/browse_annotations/get_model_list').then(response => {
  //     console.log(response); // this is necessary to show traffic?
  //     this.list = response.body;
  //   })
  // },
  methods: {
    selectModel(type) {
      this.$emit("input", type.valueOf());
    },
    getResult(newVal) {
      this.$http
        .post("/tasks/browse_annotations/set_model", { annotationFor: newVal })
        .then(response => {
          // console.log(response);
          this.$emit("model_selected", response.body);
          this.$emit("result", response.body);
          this.result = response.body;
        });
    }
  }
};
</script>