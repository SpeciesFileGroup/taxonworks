<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        v-hotkey="shortcuts"
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
        @click="searchDepictions">
        Search
      </button>
      <otus-component
        class="margin-large-bottom"
        v-model="params.base.otu_id"/>
      <scope-component
        class="margin-large-bottom"
        v-model="params.base.taxon_name_id"/>
      <ancestor-target
        class="margin-large-bottom"
        v-model="params.base.ancestor_id_target"
        :taxon-name="params.base.taxon_name_id"/>
      <collection-object-component
        class="margin-large-bottom"
        v-model="params.base.collection_object_id"/>
      <biocurations-component
        class="margin-large-bottom"
        v-model="params.base.biocuration_class_id"/>
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"/>
      <tags-component
        class="margin-large-bottom"
        target="Image"
        v-model="params.keywords"/>
      <users-component
        class="margin-large-bottom"
        v-model="params.user"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import platformKey from 'helpers/getPlatformKey.js'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import BiocurationsComponent from 'tasks/collection_objects/filter/components/filters/biocurations'
import TagsComponent from 'tasks/sources/filter/components/filters/tags'
import IdentifierComponent from 'tasks/collection_objects/filter/components/filters/identifier'
import ScopeComponent from 'tasks/nomenclature/filter/components/filters/scope'
import OtusComponent from './filters/otus'
import CollectionObjectComponent from './filters/collectionObjects'
import AncestorTarget from './filters/ancestorTarget'
import hotkey from 'plugins/v-hotkey'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Image } from 'routes/endpoints'

export default {
  components: {
    AncestorTarget,
    BiocurationsComponent,
    CollectionObjectComponent,
    IdentifierComponent,
    SpinnerComponent,
    UsersComponent,
    OtusComponent,
    TagsComponent,
    ScopeComponent
  },

  directives: {
    hotkey
  },

  emits: [
    'newSearch',
    'pagination',
    'params',
    'reset',
    'response',
    'result',
    'urlRequest'
  ],

  computed: {
    emptyParams () {
      if (!this.params) return
      return !this.params.depictions
    },

    shortcuts() {
      const keys = {}

      keys[`${platformKey()}+f`] = this.searchDepictions
      keys[`${platformKey()}+r`] = this.resetFilter

      return keys
    }
  },
  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)

    if (Object.keys(urlParams).length) {
      this.getDepictions(urlParams)
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchDepictions () {
      if (this.emptyParams) return
      const params = this.filterEmptyParams(Object.assign({}, this.params.identifier, this.params.depictions, this.params.keywords, this.params.base, this.params.user, this.params.settings))

      this.getDepictions(params)
    },
    getDepictions (params) {
      this.searching = true
      this.$emit('newSearch')
      Image.where(params).then(response => {
        this.$emit('result', response.body)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('response', response)
        this.$emit('pagination', response)
        this.$emit('params', params)
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
          per: 50,
          page: 1
        },
        base: {
          otu_id: [],
          taxon_name_id: [],
          biocuration_class_id: [],
          collection_object_id: [],
          ancestor_id_target: undefined
        },
        identifier: {
          identifier: undefined,
          identifier_exact: undefined,
          identifier_start: undefined,
          identifier_end: undefined,
          namespace_id: undefined
        },
        keywords: {
          keyword_id_and: [],
          keyword_id_or: []
        },
        depictions: {},
        collectingEvent: {},
        collectionObject: {},
        nomenclature: {},
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
      this.searchDepictions()
    },
  }
}
</script>
