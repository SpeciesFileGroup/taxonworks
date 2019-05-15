<template>
  <select v-model="mapOption">
    <option
      v-for="type in layoutTypes"
      :value="type"
      :key="type"
    >
      {{ type | humanize }}
    </option>
  </select>
</template>

<script>
export default {
  props: {
    value: {
      type: String
    },
    layoutTypes: {
      type: Array,
      required: true
    }
  },
  computed: {
    mapOption: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  filters: {
    humanize: function (value) {
      if (!value) return ''
      value = value.toString().replace(/_/g, ' ')
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  }
}
</script>
