<template>
  <div>
    <h3>Born year</h3>
    <div class="horizontal-left-content align-start field">
      <div class="margin-small-right">
        <label>Before</label>
        <input
          type="number"
          v-model="params.born_before_year">
      </div>
      <div>
        <label>After</label>
        <input
          type="number"
          v-model="params.born_after_year">
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Object,
      required: true
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
