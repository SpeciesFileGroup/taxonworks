<template>
  <input
    type="checkbox"
    :value="val"
    v-model="checked"
    @change="onChange">
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    },
    val: {
      type: [Object, String, Number],
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'change'
  ],

  data () {
    return {
      checkedProxy: false
    }
  },

  computed: {
    checked: {
      get () {
        return this.modelValue
      },
      set (val) {
        this.checkedProxy = val
      }
    }
  },

  methods: {
    onChange () {
      this.$emit('update:modelValue', this.checkedProxy)
      this.$emit('change', this.checkedProxy)
    }
  }
}
</script>