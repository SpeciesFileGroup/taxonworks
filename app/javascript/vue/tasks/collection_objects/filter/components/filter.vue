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
        @shortkey="searchForCollectionObjects"
        @click="searchForCollectionObjects">
        Search
      </button>
      <geographic-component
        v-model="params.geographic"/>
      <otu-component v-model="params.determination"/>
      <collecting-event
        v-model="params.collectingEvents"/>
      <user-component 
        @onUserslist="usersList = $event"
        v-model="params.user"/>
      <keywords-component v-model="params.keywords.keyword_ids" />
      <identifier-component v-model="params.identifier"/>
      <types-component v-model="params.types"/>
      <loan-component v-model="params.loans"/>
      <in-relationship v-model="params.relationships.biological_relationship_ids"/>
      <biocurations-component v-model="params.biocurations.biocuration_class_ids"/>
    </div>
  </div>
</template>

<script>

import OtuComponent from './filters/otu'
import CollectingEvent from './filters/collectingEvent/collectingEvent'
import UserComponent from './filters/user'
import GeographicComponent from './filters/geographic'
import KeywordsComponent from './filters/tags'
import IdentifierComponent from './filters/identifier'
import TypesComponent from './filters/types'
import LoanComponent from './filters/loan'
import InRelationship from './filters/relationship/in_relationship'
import BiocurationsComponent from './filters/biocurations'

import { GetCollectionObjects, GetCODWCA } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'

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
    BiocurationsComponent
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    },
    emptyParams() {
      if (!this.params) return 
      return !this.params.biocurations.biocuration_class_ids.length && 
        !this.params.geographic.geographic_area_ids.length &&
        !this.params.geographic.geo_json &&
        !this.params.relationships.biological_relationship_ids.length &&
        !this.params.types.is_type.length &&
        !this.params.keywords.keyword_ids.length &&
        !this.params.determination.otu_ids.length &&
        !this.params.collectingEvents.collecting_event_ids.length &&
        !Object.values(this.params.user).find(item => { return item != undefined }) &&
        !Object.values(this.params.loans).find(item => { return item != undefined }) &&
        !Object.values(this.params.identifier).find(item => { return item != undefined })
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
  methods: {
    resetFilter() {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForCollectionObjects () {
      if(this.emptyParams) return
      if(this.loadingDWCA) return
      this.searching = true
      this.result = []
      this.$emit('newSearch')
      const params = Object.assign({},  this.params.settings, this.params.biocurations, this.params.relationships, this.params.loans, this.params.types, this.params.determination, this.params.identifier, this.params.keywords, this.params.geographic, this.flatObject(this.params.collectingEvents, 'fields'), this.filterEmptyParams(this.params.user))

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
        this.$emit('urlRequest', response.url)
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
          per: 1000
        },
        biocurations: {
          biocuration_class_ids: []
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
          keyword_ids: []
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
          fields: undefined
        },
        user: {
          user_id: undefined,
          user_target: undefined,
          user_date_start: undefined,
          user_date_end: undefined
        },
        geographic: {
          geo_json: undefined,
          radius: undefined,
          spatial_geographic_areas: undefined,
          geographic_area_ids: []
        }
      }
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
        //this.DWCACount = this.DWCACount + ids[0].length
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
