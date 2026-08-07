const vueAnnotator = {
  props: {
    type: {
      type: String,
      required: true
    },
    objectType: {
      type: String,
      required: true
    },
    metadata: {
      type: Object,
      required: true
    },
    url: {
      type: String,
      required: true
    },
    globalId: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      list: [],
      urlList: undefined,
      loadOnMounted: true
    }
  },

  mounted () {
    if (this.loadOnMounted) {
      this.loadObjectsList()
    }
  },

  watch: {
    list: {
      handler () {
        this.updateCount()
      },
      deep: true
    }
  },

  methods: {
    removeFromList (id) {
      const position = this.list.findIndex(element => element.id === id)

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
    },

    loadObjectsList () {
      this.getList((typeof this.urlList == 'undefined') ? `${this.url}/${this.type}.json` : this.urlList).then(response => {
        this.list = response.body
      })
    }
  }
}

export default vueAnnotator
