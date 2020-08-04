<template>
  <div
    v-if="Object.keys(list).length"
    class="full_width overflow-scroll">
    <table class="full_width">
      <thead>
        <tr></tr>
      </thead>
      <tbody>
        <tr></tr>
      </tbody>
    </table>
  </div>
</template>

<script>

export default {
  props: {
    list: {
      type: Object,
      default: undefined
    },
    value: {
      type: Array,
      default: []
    }
  },
  computed: {
    ids: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      ascending: false
    }
  },
  methods: {
    sortTable (sortProperty) {
      let that = this
      function compare (a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (that.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (that.ascending ? 1 : -1)
        return 0
      }
      this.list.data.sort(compare)
      this.ascending = !this.ascending
    }
  }
}
</script>

<style lang="scss" scoped>
  table {
    margin-top: 0px;
  }
  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
  .overflow-scroll {
    overflow: scroll;
  }
</style>
