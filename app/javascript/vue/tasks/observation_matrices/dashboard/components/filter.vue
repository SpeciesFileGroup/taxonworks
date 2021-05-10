<template>
  <div class="panel vue-filter-container">
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
        class="button normal-input button-default full_width"
        type="button"
        :disabled="!taxonName"
        @click="sendParams">
        Search
      </button>
      <taxon-name v-model="taxonName"/>
      <otu-filter v-model="params.validity"/>
      <combinations-filter
        v-model="params.combination"/>
      <ranks-filter
        :taxon-name="taxonName"
        v-model="params.ranks"/>
      <filter-table
        v-for="(item, key) in tableFilter"
        :key="key"
        :title="key"
        v-model="tableFilter[key]"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import taxonName from './filters/taxonName'
import RanksFilter from './filters/ranks'
import OtuFilter from './filters/otus'
import FilterTable from './filters/with.vue'
import CombinationsFilter from './filters/combinations'
import { TaxonName } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    SpinnerComponent,
    CombinationsFilter,
    RanksFilter,
    OtuFilter,
    taxonName,
    FilterTable
  },
  props: {
    fieldSet: {
      type: Array,
      required: true
    }
  },
  computed: {
    rankList () {
      return this.$store.getters[GetterNames.GetRanks]
    }
  },
  data () {
    return {
      taxonName: undefined,
      searching: false,
      params: this.initParams(),
      tableFilter: {
        observation_count: undefined,
        observation_depictions: undefined,
        descriptors_scored: undefined
      }
    }
  },
  watch: {
    taxonName: {
      handler (newVal) {
        this.ranks = []
        if (newVal) {
          this.params.ancestor_id = newVal ? newVal.id : undefined
          this.$emit('onTaxon', newVal)
        } else {
          return
        }
        if (newVal.rank && !this.params.ranks.includes(newVal.rank)) {
          this.params.ranks.push(newVal.rank)
        }
      },
      deep: true
    },
    tableFilter: {
      handler (newVal) {
        this.$emit('onTableFilter', newVal)
      },
      deep: true,
      immediate: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      TaxonName.find(urlParams.ancestor_id).then(response => {
        this.taxonName = response.body
        this.params = Object.assign({}, this.params, urlParams)
        this.sendParams()
      })
    }
  },
  methods: {
    sendParams () {
      this.$emit('onSearch', this.params)
    },
    setTaxon (taxon) {
      this.taxonName = taxon
      this.params.ancestor_id = taxon.id
    },
    initParams () {
      return {
        ancestor_id: undefined,
        ranks: [],
        validity: false,
        combination: undefined,
        fieldsets: ['observations']
      }
    },
    resetFilter () {
      this.taxonName = undefined
      this.params = this.initParams()
      this.$emit('reset')
    }
  }
}
</script>
<style scoped>
  ::v-deep .vue-autocomplete-input {
    width: 100%;
  }
</style>
