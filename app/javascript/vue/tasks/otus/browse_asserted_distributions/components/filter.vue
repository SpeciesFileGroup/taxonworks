<template>
  <div class="panel">
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
      <otu-component v-model="params.base.otu_id"/>
      <nav-bar-component :otu-id="params.base.otu_id"/>
    </div>
  </div>
</template>

<script>

import OtuComponent from './filters/otu'
import NavBarComponent from './navBar'

import { GetOtuAssertedDistribution } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'

export default {
  components: {
    OtuComponent,
    SpinnerComponent,
    NavBarComponent
  },
  computed: {
    getMacKey() {
      return GetMacKey()
    }
  },
  data() {
    return {
      params: this.initParams(),
      result: [],
      searching: false
    }
  },
  watch: {
    params: {
      handler(newVal) {
        if(newVal.base.otu_id) {
          this.search()
        }
      },
      deep: true
    }
  },
  methods: {
    resetFilter() {
      this.$emit('reset')
      this.params = this.initParams()
    },
    search() {
      this.searching = true
      let params = Object.assign({}, this.params.base)

      GetOtuAssertedDistribution(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.request.responseURL)
        this.searching = false
        if(this.result.length == 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }, () => { 
        this.searching = false
      })
    },
    initParams() {
      return {
        base: {
          otu_id: undefined,
          geo_json: true,
        }
      }
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
::v-deep .btn-delete {
    background-color: #5D9ECE;
  }
</style>
