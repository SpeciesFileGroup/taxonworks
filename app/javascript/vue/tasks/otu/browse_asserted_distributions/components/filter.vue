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
      v-if="searching"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
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
import SpinnerComponent from 'components/spinner'
import { AssertedDistribution } from 'routes/endpoints'

export default {
  components: {
    OtuComponent,
    SpinnerComponent,
    NavBarComponent
  },

  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false
    }
  },

  watch: {
    params: {
      handler(newVal) {
        if (newVal.base.otu_id) {
          this.search()
        }
      },
      deep: true
    }
  },

  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },

    search () {
      const params = { ...this.params.base }

      this.searching = true
      AssertedDistribution.where(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.request.responseURL)
        if (this.result.length === 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }).finally(() => {
        this.searching = false
      })
    },

    initParams () {
      return {
        base: {
          otu_id: undefined,
          embed: ['shape'],
          extend: ['geographic_area']
        }
      }
    },

    filterEmptyParams (object) {
      const keys = Object.keys(object)

      keys.forEach(key => {
        if (object[key] === '') {
          delete object[key]
        }
      })
      return object
    }
  }
}
</script>
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
