<template>
  <div>
    <h3>Active year</h3>
    <div class="horizontal-left-content align-start field">
      <div class="margin-small-right">
        <label>Before</label>
        <input
          type="number"
          v-model="params.active_before_year">
      </div>
      <div>
        <label>After</label>
        <input
          type="number"
          v-model="params.active_after_year">
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    params: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>
