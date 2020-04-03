<template>
  <div>
    <div class="field">
      <label>Author</label>
      <input
        type="text"
        v-model="source.author">
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="source.exact_author">
        Exact
      </label>
    </div>
    <div class="field">
      <label>Authors</label>
      <smart-selector
        model="people"
        target="Author"
        @selected="addAuthor">
      </smart-selector>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    source: {
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
      authors: []
    }
  },
  watch: {
    authors: {
      handler (newVal) {
        this.source.author_ids = this.authors.map(author => { return author.id })
      },
      deep: true
    }
  },
  methods: {
    addAuthor (author) {
      this.authors.push(author)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>