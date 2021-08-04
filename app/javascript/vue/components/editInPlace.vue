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
    modelValue: {
      type: String,
    },

    legend: {
      type: String,
      default: 'Click to edit'
    }
  },

  emits: [
    'update:modelValue',
    'end'
  ],

  computed: {
    inputField: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    },
    displayLabel () {
      return this.modelValue ? this.modelValue : this.legend
    }
  },

  watch: {
    editing(newVal) {
      if(newVal) {
        this.$nextTick(() => {
          this.$refs.inputtext.focus()
        })
      }
      else {
        this.$emit('end', this.value)
      }
    }
  },

  data () {
    return {
      editing: false,
    }
  },
  methods: {
    setEdit (value) {
      this.editing = value
    }
  }
}
</script>