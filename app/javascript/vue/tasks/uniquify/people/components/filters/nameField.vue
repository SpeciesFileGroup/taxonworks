<template>
  <div class="horizontal-left-content">
    <div class="field label-above full_width margin-small-right">
      <label>{{ title }}</label>
      <input
        class="full_width"
        type="text"
        v-model="params[param]">
    </div>
    <div class="field label-above">
      <label>Wildcard</label>
      <input
        type="checkbox"
        :value="param"
        v-model="params.person_wildcard">
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
    value: {
      type: Object,
      required: true
    },
    param: {
      type: String,
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
