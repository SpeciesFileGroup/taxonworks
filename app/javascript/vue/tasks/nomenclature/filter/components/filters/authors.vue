<template>
  <div>
    <h3>Authors</h3>
    <fieldset>
      <legend>People</legend>
      <smart-selector
        model="people"
        target="Author"
        :autocomplete-params="{
          roles: ['TaxonNameAuthor']
        }"
        @selected="addAuthor"/>
      <label>
        <input
          v-model="params.taxon_name_author_ids_or"
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
import { People } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    DisplayList
  },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      authors: []
    }
  },

  watch: {
    modelValue: {
      handler (newVal, oldVal) {
        if (!newVal.taxon_name_author_ids.length && oldVal.taxon_name_author_ids.length) {
          this.authors = []
        }
      },
      deep: true
    },

    authors: {
      handler () {
        this.params.taxon_name_author_ids = this.authors.map(author => author.id)
      },
      deep: true
    }
  },

  mounted () {
    const params = URLParamsToJSON(location.href)
    const authorIds = params.taxon_name_author_ids || []

    this.params.taxon_name_author_ids_or = params.taxon_name_author_ids_or

    authorIds.forEach(id => {
      People.find(id).then(response => {
        this.addAuthor(response.body)
      })
    })
  },

  methods: {
    addAuthor (author) {
      if (!this.params.taxon_name_author_ids.includes(author.id)) {
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
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
