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
      <tags-component v-model="params.keywords"/>
      <identifier-component v-model="params.identifiers"/>
      <citation-types-component v-model="params.citation_object_type"/>
      <with-component
        title="In project"
        :values="['Both', 'Yes', 'No']"
        v-model="params.in_project"
      />
      <with-component
        title="Citations"
        v-model="params.byRecordsWith.citations"
      />
      <with-component
        title="DOI"
        v-model="params.byRecordsWith.with_doi"
      />
      <with-component
        title="Roles"
        v-model="params.byRecordsWith.roles"
      />
      <with-component
        title="Tags"
        v-model="params.byRecordsWith.tags"
      />
      <with-component
        title="Notes"
        v-model="params.byRecordsWith.notes"
      />
      <with-component
        title="Documents"
        v-model="params.byRecordsWith.documents"
      />
      <with-component
        title="Nomenclatural"
        v-model="params.byRecordsWith.nomenclature"
      />
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
import TagsComponent from './filters/tags'
import IdentifierComponent from './filters/identifiers'
import CitationTypesComponent from './filters/citationTypes'
import WithComponent from './filters/with'

export default {
  components: {
    SpinnerComponent,
    TitleComponent,
    AuthorsComponent,
    DateComponent,
    TagsComponent,
    IdentifierComponent,
    CitationTypesComponent,
    WithComponent
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
          author: undefined,
          exact_author: undefined,
          author_ids: [],
          year_start: undefined,
          year_end: undefined,
          title: undefined,
          year: undefined,
          exact_title: undefined,
          in_project: undefined
        },
        byRecordsWith: {
          citations: undefined,
          roles: undefined,
          documents: undefined,
          nomenclature: undefined,
          with_doi: undefined,
          tags: undefined,
          notes: undefined
        },
        citation_object_type: [],
        keywords: [],
        identifiers: {
          identifiers: [],
          identifiers_start: undefined,
          identifiers_end: undefined,
          identifier_exact: undefined
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
