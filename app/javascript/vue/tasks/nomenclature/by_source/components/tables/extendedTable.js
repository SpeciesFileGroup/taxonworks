import SortArray from 'helpers/sortArray'

export default {
  props: {
    list: {
      type: Array,
      require: true
    }
  },
  data () {
    return {
      ascending: false
    }
  },
  methods: {
    sortTable (sortProperty) {
      this.list = SortArray(sortProperty, this.list, this.ascending)
      this.ascending = !this.ascending
    },
    sortPages () {
      this.list.sort((a, b) => {
        a = a.pages ? a.pages.match(/\d+/g).map(item => Number(item)) : []
        b = b.pages ? b.pages.match(/\d+/g).map(item => Number(item)) : []

        for (var i = 0; i < Math.min(a.length, b.length); i++) { if (a[i] - b[i] !== 0) return this.ascending ? a[i] - b[i] : b[i] - a[i] }
        return this.ascending ? a.length - b.length : b.length - a.length
      })
      this.ascending = !this.ascending
    },
    removeCitation (citation) {
      const index = this.list.findIndex((item) => { return citation.id == item.id })
      if (index > -1) {
        this.list.splice(index, 1)
      }
    }
  }
}
