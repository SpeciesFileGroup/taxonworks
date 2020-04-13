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
        @shortkey="searchSources"
        @click="searchSources">
        Search
      </button>
      <title-component v-model="params.source"/>
      <type-component v-model="params.source.source_type"/>
      <authors-component v-model="params.source"/>
      <date-component v-model="params.source"/>
      <tags-component v-model="params.source.keyword_ids"/>
      <identifier-component v-model="params.identifier"/>
      <citation-types-component v-model="params.source.citation_object_type"/>
      <users-component v-model="params.user"/>
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
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import AuthorsComponent from './filters/authors'
import DateComponent from './filters/date'
import TagsComponent from './filters/tags'
import IdentifierComponent from './filters/identifiers'
import CitationTypesComponent from './filters/citationTypes'
import WithComponent from './filters/with'
import TypeComponent from './filters/type'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'

import { GetSources } from '../request/resources.js'

export default {
  components: {
    SpinnerComponent,
    TitleComponent,
    AuthorsComponent,
    DateComponent,
    TagsComponent,
    IdentifierComponent,
    CitationTypesComponent,
    WithComponent,
    TypeComponent,
    UsersComponent
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
    searchSources () {
      if (this.emptyParams) return
      this.searching = true
      this.$emit('newSearch')
      const params = Object.assign({}, this.params.source, this.params.byRecordsWith, this.params.identifier, this.params.user)

      GetSources(params).then(response => {
        this.$emit('result', response.body)
        this.$emit('urlRequest', response.url)
        this.$emit('pagination', response)
        this.$emit('params', this.filterEmptyParams(params))
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
          in_project: undefined,
          source_type: undefined,
          citation_object_type: [],
          keyword_ids: [],
          users: []
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
        identifier: {
          namespace_id: undefined,
          identifier: undefined,
          identifiers_start: undefined,
          identifiers_end: undefined,
          identifier_exact: undefined
        },
        user: {
          user_id: undefined,
          user_target: undefined,
          user_date_start: undefined,
          user_date_end: undefined
        }
      }
    },
    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '' || object[key] === undefined || (Array.isArray(object[key]) && !object[key].length)) {
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
