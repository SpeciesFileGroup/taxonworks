<template>
  <div>
    <h2>Authors</h2>
    <div class="field label-above">
      <label>Author</label>
      <input
        type="text"
        class="full_width"
        v-model="source.author">
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="source.exact_author">
        Exact
      </label>
    </div>
    <fieldset>
      <legend>Authors</legend>
      <smart-selector
        model="people"
        target="Author"
        :autocomplete-params="{
          roles: ['TaxonNameAuthor']
        }"
        @selected="addAuthor"/>
      <label>
        <input
          v-model="source.author_ids_or"
          type="checkbox">
        Any
      </label>
    </fieldset>
    <display-list
      :list="authors"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removeAuthor"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetPeople } from '../../request/resources'

export default {
  components: {
    SmartSelector,
    DisplayList
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
    value: {
      handler (newVal, oldVal) {
        if (!newVal.author_ids.length && oldVal.author_ids.length) {
          this.authors = []
        }
      },
      deep: true
    },
    authors: {
      handler (newVal) {
        this.source.author_ids = this.authors.map(author => { return author.id })
      },
      deep: true
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.source.author = params.author
    this.source.exact_author = params.exact_author
    this.source.author_ids_or = params.author_ids_or
    if (params.author_ids) {
      params.author_ids.forEach(id => {
        GetPeople(id).then(response => {
          this.addAuthor(response.body)
        })
      })
    }
  },
  methods: {
    addAuthor (author) {
      if (!this.source.author_ids.includes(author.id)) {
        this.authors.push(author)
      }
    },
    removeAuthor (index) {
      this.authors.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
