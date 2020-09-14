<template>
  <td
    v-if="!editing"
    style="overflow: ellipsis; height: 40px"
    @click="setEdit(true)">
    <div
      v-html="text"
      style="overflow: ellipsis; height: 40px"/>
  </td>
  <td v-else>
    <div style="overflow: ellipsis; height: 40px">
    <input
      ref="inputtext"
      @blur="setEdit(false)"
      @keypress.enter="setEdit(false)"
      v-model="text"
      type="text">
    </div>
  </td>
</template>

<script>

export default {
  props: {
    cell: {
      type: [String],
      default: undefined
    },
    cellIndex: {
      type: Number,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      editing: false,
      text: undefined,
      tmp: undefined
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
        this.tmp = this.text
        this.$nextTick(() => {
          this.$refs.inputtext.focus()
        })
      } else if (this.tmp !== this.text) {
        this.$emit('update', { [this.cellIndex]: this.text })
      }
    }
  },
  methods: {
    setEdit (value) {
      if(this.disabled) return
      this.editing = value
    }
  }
}
</script>
