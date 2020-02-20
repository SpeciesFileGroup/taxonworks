<template>
  <span
    @click="removeLine"
    style="position: absolute"
    class="button normal-input button-default add-line">-</span>
</template>

<script>
export default {
  props: {
    value: {
      type: Array,
      required: true
    },
    position: {
      type: Number,
      required: true
    }
  },
  computed: {
    lines: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  methods: {
    removeLine () {
      this.lines.splice(this.position, 1)
    }
  }

}
</script>
<style lang="scss" scoped>
  .add-line {
    width: 20px;
    height: 20px;
    text-align: center;
    z-index: 5
  }
</style>