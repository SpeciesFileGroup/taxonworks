<template>
  <div>
    <div v-if="!editing">
      <span
        v-html="displayLabel"
        @click="setEdit(true)"/>
    </div>
    <div v-else>
      <input
        ref="inputtext"
        @blur="setEdit(false)"
        @keypress.enter="setEdit(false)"
        v-model="inputField"
        type="text"/>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
    },
    legend: {
      type: String,
      default: 'Click to edit'
    }
  },
  computed: {
    inputField: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    },
    displayLabel() {
      return (this.value ? this.value : this.legend)
    }
  },
  watch: {
    editing(newVal) {
      if(newVal) {
        this.$nextTick(()=> {
          this.$refs.inputtext.focus()
        })
      }
    }
  },
  data() {
    return {
      editing: false,
    }
  },
  methods: {
    setEdit(value) {
      this.editing = value
    }
  }
}
</script>