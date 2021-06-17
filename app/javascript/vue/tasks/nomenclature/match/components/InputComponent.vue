<template>
  <div>
    <textarea
      v-model="text"
      class="full_width"
      placeholder="Write names..."
      rows="10"
    />
  </div>
</template>

<script>
export default {
  emits: ['lines'],

  data () {
    return {
      text: undefined
    }
  },

  watch: {
    text (newVal) {
      this.$emit('lines', newVal.split('\n').filter(line => line.trim().length))
    }
  }
}
</script>
