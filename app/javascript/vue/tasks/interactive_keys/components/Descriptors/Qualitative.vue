<template>
  <div>
    <select v-model="item.id">
      <option
        v-for="state in states"
        :key="state.id">
        {{ state.name }}
      </option>
    </select>
  </div>
</template>

<script>
export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    },
    value: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    selected: {
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
