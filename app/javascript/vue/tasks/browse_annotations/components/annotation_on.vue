<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in annotationType.used_on"
        :key="label">
        <button
          type="button"
          :class="{ 'button-default': (key != modelValue)}"
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
    modelValue: {
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

  emits: ['update:modelValue'],

  watch: {
    annotationType () {
      this.$emit('update:modelValue', undefined)
    }
  },

  data () {
    return {
      list: {},
      result: undefined
    }
  },

  methods: {
    selectModel (type) {
      this.$emit('update:modelValue', type)
    }
  }
};
</script>