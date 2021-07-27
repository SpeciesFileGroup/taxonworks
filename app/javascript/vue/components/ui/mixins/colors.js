import paletteColors from 'assets/styles/variables/_exports.scss'

export default {
  props: {
    color: {
      type: String,
      default: 'currentColor'
    }
  },

  computed: {
    selectedColor () {
      return paletteColors[this.color] || this.color
    }
  }
}
