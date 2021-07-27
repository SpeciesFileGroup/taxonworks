<template>
  <span
    @click="addLine"
    style="position: absolute"
    class="button normal-input button-default add-line">+</span>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    },

    position: {
      type: Number,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    lines: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    addLine () {
      this.lines.push(this.position)
    }
  }

}
</script>
<style lang="scss" scoped>
  .add-line {
    width: 20px;
    height: 20px;
    text-align: center;
  }
</style>
