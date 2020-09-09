export default {
  computed: {
    filter: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    applied () {
      return this.value
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
