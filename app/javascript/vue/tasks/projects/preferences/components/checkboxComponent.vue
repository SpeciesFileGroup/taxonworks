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
    value: {
      type: Array,
      required: true
    }, 
    val: {
      type: [Object, String, Number],
      required: true
    }
  },
  data () {
    return {
      checkedProxy: false
    }
  },
  computed: {
    checked: {
      get() {
        return this.value
      },
      set(val) {
        this.checkedProxy = val
      }
    }
  },
  methods: {
    onChange(e) {
      this.$emit('input', this.checkedProxy)
      this.$emit('change', this.checkedProxy)
    }
  }
}
</script>