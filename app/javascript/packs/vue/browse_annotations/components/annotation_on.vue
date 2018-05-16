<template>
  <div>
    <ul>
      <li
        v-for="(label, key) in annotationType.used_on"
        :key=label >
        <button
          type="button"
          :class="{ 'button-default': (key != value)}"
          class="button normal-input"
          @click="selectModel(key)">{{ label }}
        </button>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: ''
    },
    // usedOn: {
    //   type: Object,
    //   default: undefined
    // },
    annotationType: {
      type: Object,
      required: true
    }
  },

  // watch: {
  //   value(newVal) {
  //     this.annotationType.used_on = {};
  //   },
  //   annotationType(newVal) {
  //     this.annotationType.used_on = {};
  //   }
  // },
  data() {
    return {
      list: {},
      result: undefined
    };
  },
  methods: {
    selectModel(type) {   // click one of the types provided from usedOn
      this.$emit("input", type.valueOf());
      // this.$emit("model_selected", type.valueOf());
    }//,
    //setType()
  }
};
</script>