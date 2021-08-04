<template>
  <div class="horizontal-left-content">
    <div class="field label-above full_width margin-small-right">
      <label>{{ title }}</label>
      <input
        class="full_width"
        type="text"
        :disabled="disabled"
        v-model="params[param]">
    </div>
    <div class="field">
      <br>
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          :value="param"
          :disabled="disabled"
          v-model="params.person_wildcard">
        Wildcard
      </label>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      required: true
    },

    modelValue: {
      type: Object,
      required: true
    },

    param: {
      type: String,
      required: true
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  emits: ['update:modelValue'],

  computed: {
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
