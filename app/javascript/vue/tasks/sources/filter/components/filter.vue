<template>
  <div class="panel vue-filter-container">
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
      <with-component
        class="margin-large-bottom margin-medium-top"
        title="In project"
        name="params.source.in_project"
        :values="['Both', 'Yes', 'No']"
        param="in_project"
        v-model="params.source.in_project"
      />
      <title-component class="margin-large-bottom" v-model="params.source"/>
      <type-component class="margin-large-bottom" v-model="params.source.source_type"/>
      <authors-component class="margin-large-bottom" v-model="params.source"/>
      <date-component class="margin-large-bottom" v-model="params.source"/>
      <serials-component class="margin-large-bottom" v-model="params.source.serial_ids"/>
      <tags-component class="margin-large-bottom" v-model="params.source.keyword_ids"/>
      <topics-component class="margin-large-bottom" v-model="params.source.topic_ids"/>
      <identifier-component class="margin-large-bottom" v-model="params.identifier"/>
      <citation-types-component class="margin-large-bottom" v-model="params.source.citation_object_type"/>
      <users-component class="margin-large-bottom" v-model="params.user"/>
      <with-component
        class="margin-large-bottom"
        v-for="(item, key) in params.byRecordsWith"
        :key="key"
        :title="key"
        :param="key"
        v-model="params.byRecordsWith[key]"
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
import SerialsComponent from './filters/serials'
import WithComponent from './filters/with'
import TypeComponent from './filters/type'
import TopicsComponent from './filters/topics'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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
    UsersComponent,
    TopicsComponent,
    SerialsComponent
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
  mounted () {
    const urlParams = URLParamsToJSON(location.href)

    if (Object.keys(urlParams).length) {
      this.getSources(urlParams)
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchSources () {
      if (this.emptyParams) return
      const params = this.filterEmptyParams(Object.assign({}, this.params.source, this.params.byRecordsWith, this.params.identifier, this.params.user, this.params.settings))

      this.getSources(params)
    },
    getSources (params) {
      this.searching = true
      this.$emit('newSearch')
      GetSources(params).then(response => {
        this.$emit('result', response.body)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        this.$emit('params', params)
        this.searching = false
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])
        history.pushState(null, null, `/tasks/sources/filter?${urlParams.toString()}`)
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
          author_ids_or: undefined,
          query_term: undefined,
          author: undefined,
          exact_author: undefined,
          author_ids: [],
          year_start: undefined,
          year_end: undefined,
          title: undefined,
          year: undefined,
          exact_title: undefined,
          in_project: true,
          source_type: undefined,
          citation_object_type: [],
          keyword_ids: [],
          topic_ids: [],
          users: [],
          serial_ids: []
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
    loadPage (page) {
      this.params.settings.page = page
      this.searchSources()
    },
  }
}
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
