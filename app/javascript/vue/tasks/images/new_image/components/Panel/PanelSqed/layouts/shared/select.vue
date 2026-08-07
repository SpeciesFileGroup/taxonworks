<template>
  <select v-model="mapOption">
    <option
      v-for="type in layoutTypes"
      :value="type"
      :key="type"
    >
      {{ humanize(type) }}
    </option>
  </select>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: String
    },
    layoutTypes: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    mapOption: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    humanize (value) {
      if (!value) return ''
      value = value.toString().replace(/_/g, ' ')
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  }
}
</script>
