<template>
  <div class="panel filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        v-shortkey="[getMacKey, 'r']"
        @shortkey="resetFilter"
        @click="resetFilter">Reset
      </span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching"
    />
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        :disabled="emptyParams"
        v-shortkey="[getMacKey, 'f']"
        @shortkey="searchForCollectionObjects"
        @click="searchForCollectionObjects">
        Search
      </button>
      <title-component v-model="params.source"/>
      <authors-component v-model="params.source"/>
      <date-component v-model="params.source"/>
    </div>
  </div>
</template>

<script>

import TitleComponent from './filters/title'
import { GetSources } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import AuthorsComponent from './filters/authors'
import DateComponent from './filters/date'

export default {
  components: {
    SpinnerComponent,
    TitleComponent,
    AuthorsComponent,
    DateComponent
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    },
    emptyParams () {
      if (!this.params) return
      return !this.params.source
    }
  },
  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false,
      perRequest: 10
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForCollectionObjects () {
      if (this.emptyParams) return
      this.searching = true
      this.$emit('newSearch')
      const params = Object.assign({}, this.params.source)

      GetSources(params).then(response => {
        this.$emit('result', response.body)
        this.$emit('urlRequest', response.url)
        this.$emit('pagination', response)
        this.searching = false
        if (response.body.length === this.params.settings.per) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }, () => { 
        this.searching = false
      })
    },
    initParams () {
      return {
        settings: {
          per: 500,
          page: 1
        },
        source: {
          query_term: undefined,
          project_id: undefined,
          author: undefined,
          exact_author: undefined,
          author_ids: [],
          year_start: undefined,
          year_end: undefined,
          title: undefined,
          year: undefined,
          exact_title: undefined,
          citations: undefined,
          roles: undefined,
          documentation: undefined,
          nomenclature: undefined,
          with_doi: undefined,
          citation_object_type: undefined,
          tags: undefined,
          notes: undefined,
          keyword_ids: [],
          identifiers: []
        }
      }
    },
    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '') {
          delete object[key]
        }
      })
      return object
    },
    flatObject (object, key) {
      const tmp = Object.assign({}, object, object[key])
      delete tmp[key]
      return tmp
    },
  }
}
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
