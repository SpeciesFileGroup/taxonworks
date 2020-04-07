<template>
  <td 
    v-if="!editing"
    v-html="text"
    @click="setEdit(true)"/>
  <td v-else>
    <input
      ref="inputtext"
      @blur="setEdit(false)"
      @keypress.enter="setEdit(false)"
      v-model="text"
      type="text">
  </td>
</template>

<script>

export default {
  props: {
    cell: {
      type: [String],
      default: undefined
    }
  },
  data () {
    return {
      editing: false,
      text: undefined
    }
  },
  watch: {
    cell: {
      handler (newVal) {
        this.text = newVal
      },
      immediate: true
    },
    editing (newVal) {
      if (newVal) {
        this.$nextTick(() => {
          this.$refs.inputtext.focus()
        })
      } else {
        this.$emit('update', this.text)
      }
    }
  },
  methods: {
    setEdit (value) {
      this.editing = value
    }
  }
}
</script>
