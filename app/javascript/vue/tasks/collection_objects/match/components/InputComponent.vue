<template>
  <div>
    <textarea
      v-model="text"
      class="full_width"
      placeholder="Write names..."
      rows="10">
    </textarea>
  </div>
</template>

<script>
export default {
  data () {
    return {
      text: undefined
    }
  },
  watch: {
    text (newVal) {
      this.$emit('lines', newVal.split('\n').filter(line => { return line.trim().length }))
    }
  }
}
</script>
