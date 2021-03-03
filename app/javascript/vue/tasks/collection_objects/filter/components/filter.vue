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
        :disabled="emptyParams"
        v-shortkey="[getMacKey, 'f']"
        @shortkey="searchForCollectionObjects(parseParams)"
        @click="searchForCollectionObjects(parseParams)">
        Search
      </button>
      <geographic-component
        class="margin-large-bottom margin-medium-top"
        v-model="params.geographic"/>
      <otu-component
        class="margin-large-bottom"
        v-model="params.determination"/>
      <collecting-event
        class="margin-large-bottom"
        v-model="params.collectingEvents"/>
      <user-component
        class="margin-large-bottom"
        @onUserslist="usersList = $event"
        v-model="params.user"/>
      <keywords-component
        class="margin-large-bottom"
        v-model="params.keywords" />
      <repository-component
        class="margin-large-bottom"
        v-model="params.repository.repository_id"/>
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"/>
      <types-component
        class="margin-large-bottom"
        v-model="params.types"/>
      <loan-component
        class="margin-large-bottom"
        v-model="params.loans"/>
      <in-relationship
        class="margin-large-bottom"
        v-model="params.relationships.biological_relationship_ids"/>
      <biocurations-component
        class="margin-large-bottom"
        v-model="params.biocurations.biocuration_class_ids"/>
      <with-component
        class="margin-large-bottom"
        v-for="(item, key) in params.byRecordsWith"
        :key="key"
        :title="key"
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

import { GetCollectionObjects, GetCODWCA } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
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
    WithComponent
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    },
    parseParams () {
      return Object.assign({}, this.params.settings, this.params.byRecordsWith, this.params.biocurations, this.params.relationships, this.params.loans, this.params.types, this.params.determination, this.params.identifier, this.params.keywords, this.params.geographic, this.params.repository, this.flatObject(this.params.collectingEvents, 'fields'), this.filterEmptyParams(this.params.user))
    },
    emptyParams () {
      if (!this.params) return
      return !this.params.biocurations.biocuration_class_ids.length &&
        !this.params.geographic.geographic_area_ids.length &&
        !this.params.geographic.geo_json.length &&
        !this.params.relationships.biological_relationship_ids.length &&
        !this.params.types.is_type.length &&
        !this.params.keywords.keyword_id_and.length &&
        !this.params.keywords.keyword_id_or.length &&
        !this.params.determination.otu_ids.length &&
        !this.params.determination.ancestor_id &&
        !this.params.repository.repository_id &&
        !this.params.collectingEvents.fields.length &&
        !this.params.collectingEvents.collecting_event_ids.length &&
        Object.keys(this.params.collectingEvents.fields).length <= 1 &&
        !Object.values(this.params.collectingEvents).find(item => item && item.length) &&
        !Object.values(this.params.user).find(item => { return item !== undefined }) &&
        !Object.values(this.params.loans).find(item => { return item !== undefined }) &&
        !Object.values(this.params.identifier).find(item => { return item !== undefined }) &&
        !Object.values(this.params.byRecordsWith).find(item => (item !== undefined))
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
  mounted () {
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
    searchForCollectionObjects (params) {
      if (this.loadingDWCA) return
      this.searching = true
      this.result = []
      this.$emit('newSearch')

      GetCollectionObjects(params).then(response => {
        this.coList = response.body
        this.DWCACount = 0
        if(response.body.data.length) {
          this.result = response.body.data
          this.DWCASearch = response.body.data.filter(item => { return !this.isIndexed(item)})
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
          collecting_events: undefined,
          determinations: undefined,
          identifiers: undefined,
          repository: undefined
        },
        relationships: {
          biological_relationship_ids: []
        },
        loans: {
          on_loan: undefined,
          loaned: undefined,
          never_loaned: undefined
        },
        types: {
          is_type: []
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
        determination: {
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
          fields: []
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
          geographic_area_ids: []
        },
        repository: {
          repository_id: undefined
        }
      }
    },
    loadPage(page) {
      this.params.settings.page = page 
      this.searchForCollectionObjects(this.parseParams)
    },
    setDays(days) {
      var date = new Date();
      date.setDate(date.getDate() - days);
      return date.toISOString().slice(0,10);
    },
    filterEmptyParams(object) {
      let keys = Object.keys(object)
      keys.forEach(key => {
        if(object[key] === '') {
          delete object[key]
        }
      })
      return object
    },
    flatObject(object, key) {
      let tmp = Object.assign({}, object, object[key])
      delete tmp[key]
      return tmp
    },
    getDWCATable(list) {
      const IDS = list.map(item => { return item[0] })
      const chunk = IDS.length / this.perRequest

      var i, j;
      let chunkArray = []
      for (i = 0,j = IDS.length; i < j; i += chunk) {
          chunkArray.push(IDS.slice(i,i+chunk))
      }
      this.getDWCA(chunkArray)
    },
    isIndexed(object) {
      return object.find((item, index) => {
        return item != null && index > 0
      })
    },
    getDWCA(ids) {
      if(ids.length) {
        this.loadingDWCA = true
        let promises = []
        ids[0].forEach(id => {
          promises.push(GetCODWCA(id).then(response => {
            this.DWCACount++
            this.$set(this.coList.data, this.coList.data.findIndex(item => { return item[0] === id }), response.body)
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
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
