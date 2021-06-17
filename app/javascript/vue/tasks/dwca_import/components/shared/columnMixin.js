export default {

  props: {
    modelValue: {
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    filter: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },
    applied () {
      return this.modelValue
    }
  },
  data () {
    return {
      show: false
    }
  },
  created () {
    window.addEventListener('click', this.close)
  },
  methods: {
    close (event) {
      if (!this.$el.contains(event.target)) {
        this.show = false
      }
    }
  },
  beforeDestroy () {
    window.removeEventListener('click', this.close)
  }
}
