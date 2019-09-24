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
      <geographic-component/>
      <otu-component v-model="params.base.otu_id"/>
      <date-component/>
      <user-component/>
    </div>
  </div>
</template>

<script>

import OtuComponent from './filters/otu'
import DateComponent from './filters/collectingEvent'
import UserComponent from './filters/user'
import GeographicComponent from './filters/geographic'

import { GetCollectionObjects } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'

export default {
  components: {
    SpinnerComponent,
    OtuComponent,
    DateComponent,
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
      let params = Object.assign({}, this.filterEmptyParams(this.params.taxon), this.params.related, this.params.base)
      params.updated_since = params.updated_since ? this.setDays(params.updated_since) : undefined

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
        taxon: {
          name: undefined,
          author: undefined,
          year: undefined
        },
        base: {
          otu_id: undefined
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
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }

  .filter-container {
    width: 400px;
  }
</style>
