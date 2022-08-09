const paletteColors = {
  'background': '#f7f8fc',
  'black': '#444444',
  'create': '#9ccc65',
  'update': '#9ccc65',
  'data': '#006ebf',
  'primary': '#5D9ECE',
  'destroy': '#F44336',
  'secondary': '#5a1321',
  'warning': '#ff8c00',
  'attention': '#FFDA44',
  'white': '#FFFFFF'
}

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
