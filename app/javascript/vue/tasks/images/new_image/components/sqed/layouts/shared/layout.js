import SelectComponent from '../shared/select'

export default {
  components: { SelectComponent },

  props: {
    modelValue: {
      type: Object
    },
    layoutTypes: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    newType: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
