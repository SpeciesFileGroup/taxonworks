import SelectComponent from '../shared/select'

export default {
  components: {
    SelectComponent
  },
  props: {
    value: {
      type: Object
    },
    layoutTypes: {
      type: Array,
      required: true
    }
  },
  computed: {
    newType: {
      get() {
        return this.value
      },
      set(value) {
        this.value = value
      }
    }
  }
}