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
    usedOn: {
      type: Object,
      default: undefined
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
  },
  data() {
    return {
      list: {},
      result: undefined
    };
  },
  methods: {
    selectModel(type) {
      this.$emit("input", type.valueOf());
    },
    getResult(newVal) {
      this.$http
        .post("/tasks/browse_annotations/set_model", { annotationFor: newVal })
        .then(response => {
          this.$emit("model_selected", response.body);
          this.$emit("result", response.body);
          this.result = response.body;
        });
    }
  }
};
</script>