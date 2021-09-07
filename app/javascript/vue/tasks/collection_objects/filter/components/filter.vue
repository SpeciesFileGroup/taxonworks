<template>
  <div
    class="panel vue-filter-container"
    v-hotkey="shortcuts">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <button
        type="button"
        data-icon="w_reset"
        class="button circle-button button-default center-icon no-margin"
        @click="resetFilter"/>
    </div>
    <spinner-component
      v-if="searching"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />

    <spinner-component
      :full-screen="true"
      :legend="`Building ${ DWCACount } ... ${ DWCASearch.length } unindexed records`"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loadingDWCA"
    />
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        :disabled="isParamsEmpty"
        @click="searchForCollectionObjects(parseParams)">
        Search
      </button>
      <geographic-component
        class="margin-large-bottom margin-medium-top"
        v-model="params.geographic"/>
      <otu-component
        class="margin-large-bottom"
        v-model="params.determination"/>
      <repository-component
        class="margin-large-bottom"
        v-model="params.repository.repository_id"/>
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"/>
      <preparation-types
        class="margin-large-bottom"
        v-model="params.preparation_type_id"/>
      <biocurations-component
        class="margin-large-bottom"
        v-model="params.biocurations.biocuration_class_ids"/>
      <collecting-event
        class="margin-large-bottom"
        v-model="params.collectingEvents"/>
      <collectors-component
        class="margin-large-bottom"
        role="Collector"
        title="Collectors"
        klass="CollectingEvent"
        param-people="collector_id"
        param-any="collector_ids_or"
        v-model="params.collectors"/>
      <keywords-component
        class="margin-large-bottom"
        v-model="params.keywords" />
      <types-component
        class="margin-large-bottom"
        v-model="params.types"/>
      <in-relationship
        class="margin-large-bottom"
        v-model="params.relationships.biological_relationship_ids"/>
      <loan-component
        class="margin-large-bottom"
        v-model="params.loans"/>
      <user-component
        class="margin-large-bottom"
        @onUserslist="usersList = $event"
        v-model="params.user"/>
      <buffered-component v-model="params.buffered"/>
      <with-component
        class="margin-large-bottom"
        v-for="(item, key) in params.byRecordsWith"
        :key="key"
        :title="key.replace('with_', '')"
        :param="key"
        v-model="params.byRecordsWith[key]"/>
    </div>
  </div>
</template>

<script>

import OtuComponent from './filters/otu'
import CollectingEvent from './filters/collectingEvent/collectingEvent'
import UserComponent from './filters/user'
import GeographicComponent from './filters/geographic'
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import IdentifierComponent from './filters/identifier'
import TypesComponent from './filters/types'
import LoanComponent from './filters/loan'
import InRelationship from './filters/relationship/in_relationship'
import BiocurationsComponent from './filters/biocurations'
import RepositoryComponent from './filters/repository.vue'
import WithComponent from 'tasks/sources/filter/components/filters/with'
import BufferedComponent from './filters/buffered.vue'
import PreparationTypes from './filters/preparationTypes'
import CollectorsComponent from './filters/shared/people'

import SpinnerComponent from 'components/spinner'
import platformKey from 'helpers/getPlatformKey.js'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { CollectionObject } from 'routes/endpoints'

export default {
  components: {
    BufferedComponent,
    SpinnerComponent,
    OtuComponent,
    CollectingEvent,
    UserComponent,
    GeographicComponent,
    KeywordsComponent,
    IdentifierComponent,
    TypesComponent,
    LoanComponent,
    InRelationship,
    BiocurationsComponent,
    RepositoryComponent,
    WithComponent,
    PreparationTypes,
    CollectorsComponent
  },

  emits: [
    'newSearch',
    'reset',
    'result',
    'urlRequest',
    'pagination'
  ],

  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+r`] = this.resetFilter
      keys[`${platformKey()}+f`] = this.searchForCollectionObjects

      return keys
    },

    parseParams () {
      return Object.assign({}, { preparation_type_id: this.params.preparation_type_id }, this.params.collectors, this.params.settings, this.params.buffered.text, this.params.buffered.exact, this.params.byRecordsWith, this.params.biocurations, this.params.relationships, this.params.loans, this.params.types, this.params.determination, this.params.identifier, this.params.keywords, this.params.geographic, this.params.repository, this.flatObject(this.params.collectingEvents, 'fields'), this.filterEmptyParams(this.params.user))
    },

    isParamsEmpty () {
      return !(this.params.biocurations.biocuration_class_ids.length ||
        this.params.geographic.geographic_area_id?.length ||
        this.params.geographic.geo_json?.length ||
        this.params.relationships.biological_relationship_ids.length ||
        this.params.types.is_type.length ||
        this.params.keywords.keyword_id_and.length ||
        this.params.keywords.keyword_id_or.length ||
        this.params.collectors.collector_id.length ||
        this.params.determination.otu_ids.length ||
        this.params.determination.determiner_id.length ||
        this.params.determination.ancestor_id ||
        this.params.repository.repository_id ||
        this.params.collectingEvents.collecting_event_ids.length ||
        this.params.preparation_type_id.length ||
        Object.keys(this.params.collectingEvents.fields).length ||
        Object.values(this.params.collectingEvents).find(item => item && item.length) ||
        Object.values(this.params.user).find(item => item) ||
        Object.values(this.params.loans).find(item => item) ||
        Object.values(this.params.identifier).find(item => item) ||
        Object.values(this.params.byRecordsWith).some(item => item !== undefined) ||
        Object.values(this.params.buffered.text).find(item => item)
      )
    }
  },

  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false,
      perRequest: 10,
      coList: [],
      usersList: [],
      loadingDWCA: false,
      DWCACount: 0,
      DWCASearch: 0
    }
  },

  created () {
    const urlParams = URLParamsToJSON(location.href)

    if (Object.keys(urlParams).length) {
      urlParams.geo_json = urlParams.geo_json ? JSON.stringify(urlParams.geo_json) : []
      this.searchForCollectionObjects(urlParams)
    }
  },

  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },

    searchForCollectionObjects (params = this.parseParams) {
      if (this.loadingDWCA) return
      this.searching = true
      this.result = []
      this.$emit('newSearch')

      CollectionObject.dwcIndex(params).then(response => {
        this.coList = response.body
        this.DWCACount = 0
        if (response.body.data.length) {
          this.result = response.body.data
          this.DWCASearch = response.body.data.filter(item => !this.isIndexed(item))
          if (this.DWCASearch.length) {
            this.getDWCATable(this.DWCASearch)
          } else {
            this.$emit('result', { column_headers: this.coList.column_headers, data: this.result })
          }
        } else {
          this.$emit('result', this.coList)
        }
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])
        history.pushState(null, null, `/tasks/collection_objects/filter?${urlParams.toString()}`)
        this.searching = false
        if(this.result.length === this.params.settings.per) {
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
        biocurations: {
          biocuration_class_ids: []
        },
        byRecordsWith: {
          collecting_event: undefined,
          depictions: undefined,
          geographic_area: undefined,
          georeferences: undefined,
          identifiers: undefined,
          taxon_determinations: undefined,
          type_material: undefined,
          repository: undefined,
          dwc_indexed: undefined,
          with_buffered_collecting_event: undefined,
          with_buffered_determinations: undefined,
          with_buffered_other_labels: undefined
        },
        buffered: {
          text: {
            buffered_collecting_event: undefined,
            buffered_determinations: undefined,
            buffered_other_labels: undefined
          },
          exact: {
            exact_buffered_collecting_event: undefined,
            exact_buffered_determinations: undefined,
            exact_buffered_other_labels: undefined
          }
        },
        relationships: {
          biological_relationship_ids: []
        },
        loans: {
          on_loan: undefined,
          loaned: undefined,
          never_loaned: undefined
        },
        preparation_type_id: [],
        types: {
          is_type: [],
          type_type: []
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
        collectors: {
          collector_id: [],
          collector_ids_or: false
        },
        determination: {
          determiner_id_or: [],
          determiner_id: [],
          otu_ids: [],
          current_determinations: undefined,
          ancestor_id: undefined,
          validity: undefined
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
        repository: {
          repository_id: undefined
        }
      }
    },

    loadPage (page) {
      this.params.settings.page = page
      this.searchForCollectionObjects(this.parseParams)
    },

    setDays (days) {
      const date = new Date()
      date.setDate(date.getDate() - days)
      return date.toISOString().slice(0, 10)
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

    getDWCATable (list) {
      const IDS = list.map(item => item[0])
      const chunk = IDS.length / this.perRequest
      const chunkArray = []
      let i, j

      for (i = 0,j = IDS.length; i < j; i += chunk) {
        chunkArray.push(IDS.slice(i, i + chunk))
      }
      this.getDWCA(chunkArray)
    },

    isIndexed (object) {
      return object.find((item, index) => item != null && index > 0)
    },

    getDWCA (ids) {
      if (ids.length) {
        this.loadingDWCA = true
        const promises = []
        ids[0].forEach(id => {
          promises.push(CollectionObject.dwc(id).then(response => {
            const index = this.coList.data.findIndex(item => item[0] === id)

            this.DWCACount++
            this.coList.data[index] = response.body
          }, (response) => {
            this.loadingDWCA = false
            TW.workbench.alert.create(`Error: ${response}`, 'warning')
          }))
        })
        Promise.all(promises).then(() => {
          ids.splice(0, 1)
          this.$emit('result', { column_headers: this.coList.column_headers, data: this.result })
          this.getDWCA(ids)
        })
      } else {
        this.loadingDWCA = false
      }
    }
  }
}
</script>
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
