<template>
  <div class="panel filter-container">
    <div class="flex-separate content middle action-line">
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
        v-shortkey="[getMacKey, 'f']"
        @shortkey="searchForCollectionObjects()"
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
      <keywords-component v-model="params.keywords.keywords_id" />
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
    }
  },
  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false,
      perRequest: 10,
      coList: [],
      usersList: []
    }
  },
  methods: {
    resetFilter() {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForCollectionObjects () {
      this.searching = true
      const params = Object.assign({}, this.params.biocurations, this.params.relationships, this.params.loans, this.params.types, this.params.determination, this.params.identifier, this.params.keywords, this.params.geographic, this.flatObject(this.params.collectingEvents, 'fields'), this.filterEmptyParams(this.params.user))

      GetCollectionObjects(params).then(response => {
        this.coList = response.body
        this.getDWCATable(response.body)
        this.$emit('urlRequest', response.url)
        this.searching = false
        if(this.result.length === 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }, () => { 
        this.searching = false
      })
    },
    initParams () {
      return {
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
          keywords_id: []
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
          collecting_event_partial_matches: [],
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
      const IDS = list.map(item => { return item.id })
      const chunk = IDS.length / this.perRequest

      var i, j;
      let chunkArray = []
      for (i = 0,j = IDS.length; i < j; i += chunk) {
          chunkArray.push(IDS.slice(i,i+chunk))
      }
      this.getDWCA(chunkArray)
    },
    getDWCA(ids) {
      if(ids.length) {
        let promises = []
        ids[0].forEach(id => {
          promises.push(GetCODWCA(id).then(response => {
            let dwcaObject = response.body
            let user = this.usersList.find(user => { return user.user.id === dwcaObject.updated_by_id })
            dwcaObject.updated_by = (user ? user.user.name : undefined)
            this.result.push(Object.assign({}, dwcaObject, this.coList.find(item => { return dwcaObject.dwc_occurrence_object_id == item.id })))
          }))
        })
        Promise.all(promises).then(() => {
          ids.splice(0, 1)
          this.$emit('result', this.result)
          this.getDWCA(ids)
        })
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
