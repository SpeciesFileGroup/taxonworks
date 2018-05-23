<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in annotationType.used_on"
        :key=label >
        <button
          type="button"
          :class="{ 'button-default': (key != value)}"
          class="button normal-input biocuration-toggle-button"
          @click="selectModel(key)">
          {{ label }}
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
    annotationType: {
      type: Object,
      required: true
    },
    onModel: {
      type: String,
      default: ''
    }
  },

  watch: {
    annotationType() {
      this.$emit('input', undefined); // clear the selected annotation_on model button
    }
  },
  data() {
    return {
      list: {},
      result: undefined
    };
  },
  methods: {
    selectModel(type) {   // clicked one of the types provided from usedOn
      this.$emit("input", type.valueOf());
    }
  }
};
</script>