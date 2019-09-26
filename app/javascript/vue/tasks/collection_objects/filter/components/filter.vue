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
      <otu-component v-model="params.otus"/>
      <collecting-event
        v-model="params.collectingEvents"/>
      <user-component/>
    </div>
  </div>
</template>

<script>

import OtuComponent from './filters/otu'
import CollectingEvent from './filters/collectingEvent'
import UserComponent from './filters/user'
import GeographicComponent from './filters/geographic'

import { GetCollectionObjects } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'

export default {
  components: {
    SpinnerComponent,
    OtuComponent,
    CollectingEvent,
    UserComponent,
    GeographicComponent
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
      searching: false
    }
  },
  methods: {
    resetFilter() {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForCollectionObjects () {
      this.searching = true
      const params = Object.assign({}, this.params.otus, this.params.geographic, this.params.collectingEvents, this.params.user)

      GetCollectionObjects(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
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
        otus: {
          otu_ids: [],
          otu_descendants: undefined
        },
        collectingEvents: {
          collecting_event_ids: [],
          start_date: undefined,
          end_date: undefined
        },
        user: {
          user_start_date: undefined,
          user_end_date: undefined
        },
        geographic: {
          geo_json: undefined,
          spatial_geographic_areas: false,
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
    }
  }
}

/*
      :in_labels,
      :in_verbatim_locality,
      :geo_json,
      :wkt,
      :radius,
      :start_date,
      :end_date,
      :partial_overlap_dates,
      keyword_ids: [],
      */
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }

  .filter-container {
    width: 400px;
  }
</style>
