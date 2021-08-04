const vueRadialObject = {
  props: {
    type: {
      type: String,
      required: true
    },

    metadata: {
      type: Object,
      required: true
    },

    globalId: {
      type: String,
      required: true
    }
  },

  emits: ['updateCount'],

  data () {
    return {
      list: [],
      urlList: undefined
    }
  },

  mounted () {
    this.getList((typeof this.urlList === 'undefined') ? `/${this.metadata.recent_url}&per=20` : this.urlList).then(response => {
      this.list = response.body
    })
  },

  watch: {
    list: {
      handler () {
        this.updateCount()
      }
    }
  },

  methods: {
    removeFromList (id) {
      const position = this.list.findIndex(element => element.id == id)

      if (position > -1) {
        this.list.splice(position, 1)
      }
    },

    removeItem (item) {
      this.destroy(`/${this.type}/${item.id}`, item).then(response => {
        this.removeFromList(item.id)
      })
    },

    updateCount () {
      this.$emit('updateCount', this.list.length)
    }
  }
}

export default vueRadialObject
