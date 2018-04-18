<template>
  <div>
    <ul>
      <li 
        v-for="label in annotationType.used_on"      
        :key=label >
        <button
          type="button"
          :class="{ 'button-default': (label != value)}"
          class="button normal-input"
          @click="selectModel(label)">{{ label }}
        </button>
      </li>
    </ul>
  <!--<span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>-->
    <!--class="button normal-input"-->

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