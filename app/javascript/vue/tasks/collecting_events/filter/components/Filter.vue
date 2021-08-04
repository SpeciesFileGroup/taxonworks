<template>
  <div class="panel vue-filter-container">
    <div
      class="flex-separate content middle action-line"
      v-hotkey="shortcuts">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
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
        @click="searchCollectingEvents">
        Search
      </button>
      <geographic-area
        class="margin-large-bottom margin-medium-top"
        v-model="params.geographic"
      />
      <filter-determinations
        class="margin-large-bottom"
        v-model="params.determination"/>
      <filter-identifiers
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <filter-collectors
        class="margin-large-bottom"
        v-model="params.collectors"
        role="Collector"
        title="Collectors"
        klass="CollectingEvent"
        param-people="collector_id"
        param-any="collector_ids_or"
      />
      <filter-material
        class="margin-large-bottom"
        v-model="params.types"
      />
      <filter-keywords
        class="margin-large-bottom"
        v-model="params.keywords"
      />
      <users-component
        class="margin-large-bottom"
        v-model="params.user"
      />
      <filter-attributes
        v-model="params.collectingEvents"/>
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

import SpinnerComponent from 'components/spinner'
import platformKey from 'helpers/getMacKey.js'

import FilterIdentifiers from 'tasks/collection_objects/filter/components/filters/identifier'
import GeographicArea from 'tasks/collection_objects/filter/components/filters/geographic'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import WithComponent from 'tasks/sources/filter/components/filters/with'
import FilterAttributes from 'tasks/collection_objects/filter/components/filters/collectingEvent/collectingEvent'
import FilterKeywords from 'tasks/sources/filter/components/filters/tags'
import FilterDeterminations from 'tasks/collection_objects/filter/components/filters/otu'
import FilterMaterial from 'tasks/collection_objects/filter/components/filters/types'
import FilterCollectors from 'tasks/collection_objects/filter/components/filters/shared/people'

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { CollectingEvent } from 'routes/endpoints'

export default {
  components: {
    SpinnerComponent,
    WithComponent,
    UsersComponent,
    GeographicArea,
    FilterAttributes,
    FilterDeterminations,
    FilterIdentifiers,
    FilterKeywords,
    FilterMaterial,
    FilterCollectors
  },

  emits: [
    'reset',
    'newSearch',
    'result',
    'pagination',
    'urlRequest',
    'params'
  ],

  computed: {
    emptyParams () {
      return this.params === this.initParams()
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+r`] = this.resetFilter
      keys[`${platformKey()}+f`] = this.searchCollectingEvents

      return keys
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

  created () {
    const urlParams = URLParamsToJSON(location.href)

    if (Object.keys(urlParams).length) {
      this.getCollectingEvents(urlParams)
    }
  },

  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },

    searchCollectingEvents () {
      if (this.emptyParams) return
      const params = this.filterEmptyParams(Object.assign({}, this.params.keywords, this.params.identifier, this.params.determination, this.params.geographic, this.params.byRecordsWith, this.params.user, this.params.settings, this.flatObject(this.params.collectingEvents, 'fields')))

      this.getCollectingEvents(params)
    },

    getCollectingEvents (params) {
      this.searching = true
      this.$emit('newSearch')
      CollectingEvent.where(params).then(response => {
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])

        this.$emit('result', response.body)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        this.$emit('params', params)

        history.pushState(null, null, `/tasks/collecting_events/filter?${urlParams.toString()}`)
        if (response.body.length === this.params.settings.per) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }).finally(() => {
        this.searching = false
      })
    },

    initParams () {
      return {
        settings: {
          per: 500,
          page: 1
        },
        byRecordsWith: {
          collection_objects: undefined,
          depictions: undefined,
          geographic_area: undefined,
          georeferences: undefined,
          identifiers: undefined
        },
        identifier: {
          identifier: undefined,
          identifier_exact: undefined,
          identifier_start: undefined,
          identifier_end: undefined,
          namespace_id: undefined
        },
        determination: {
          determiner_id_or: [],
          determiner_id: [],
          otu_ids: [],
          current_determinations: undefined,
          ancestor_id: undefined,
          validity: undefined
        },
        keywords: {
          keyword_id_and: [],
          keyword_id_or: []
        },
        collectors: {
          collector_ids: [],
          collector_ids_or: false
        },
        collectingEvents: {
          collecting_event_ids: [],
          start_date: undefined,
          end_date: undefined,
          partial_overlap_dates: undefined,
          collecting_event_wildcards: [],
          fields: {}
        },
        user: {
          user_id: undefined,
          user_target: undefined,
          user_date_start: undefined,
          user_date_end: undefined
        },
        geographic: {
          geo_json: [],
          radius: undefined,
          spatial_geographic_areas: undefined,
          geographic_area_id: []
        },
        types: {
          is_type: [],
          type_type: []
        },
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
      this.searchCollectingEvents()
    }
  }
}
</script>
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
