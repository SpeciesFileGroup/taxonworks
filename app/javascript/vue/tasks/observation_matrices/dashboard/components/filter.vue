<template>
  <div class="vue-filter-container flex-col gap-medium">
    <div class="panel">
      <div class="flex-separate content middle">
        <VBtn
          color="primary"
          medium
          :disabled="!taxonName"
          @click="sendParams"
        >
          Search
        </VBtn>
        <VBtn
          color="primary"
          circle
          @click="resetFilter"
        >
          <VIcon
            name="reset"
            x-small
          />
        </VBtn>
      </div>
    </div>
    <VSpinner
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px' }"
      v-if="searching"
    />

    <FacetTaxonName v-model="taxonName" />
    <FacetOtu v-model="params" />
    <FacetCombination v-model="params.combination" />
    <FacetRanks
      :taxon-name="taxonName"
      v-model="params.ranks"
    />
    <FacetWith
      v-for="(_, param) in tableFilter"
      :key="param"
      :param="param"
      :title="param.replaceAll('_', ' ')"
      v-model="tableFilter"
    />
  </div>
</template>

<script>
import VSpinner from '@/components/ui/VSpinner'
import FacetTaxonName from './filters/taxonName'
import FacetRanks from './filters/ranks'
import FacetOtu from './filters/otus'
import FacetCombination from './filters/combinations.vue'
import CombinationsFilter from './filters/combinations'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { TaxonName } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    VSpinner,
    CombinationsFilter,
    FacetRanks,
    FacetOtu,
    FacetTaxonName,
    FacetCombination,
    FacetWith,
    VBtn,
    VIcon
  },

  props: {
    fieldSet: {
      type: Array,
      required: true
    }
  },

  emits: ['onSearch', 'onTableFilter', 'onTaxon', 'reset'],

  computed: {
    rankList() {
      return this.$store.getters[GetterNames.GetRanks]
    }
  },

  data() {
    return {
      taxonName: undefined,
      searching: false,
      params: this.initParams(),
      tableFilter: {
        otu_observation_count: undefined,
        otu_observation_depictions: undefined,
        descriptors_scored_for_otu: undefined
      }
    }
  },

  watch: {
    taxonName: {
      handler(newVal) {
        this.ranks = []
        if (newVal) {
          this.params.taxon_name_id = newVal ? newVal.id : undefined
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
      handler(newVal) {
        this.$emit('onTableFilter', newVal)
      },
      deep: true,
      immediate: true
    }
  },

  mounted() {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      TaxonName.find(urlParams.taxon_name_id).then((response) => {
        this.taxonName = response.body
        this.params = Object.assign({}, this.params, urlParams)
        this.sendParams()
      })
    }
  },

  methods: {
    sendParams() {
      this.$emit('onSearch', this.params)
    },

    setTaxon(taxon) {
      this.taxonName = taxon
      this.params.taxon_name_id = taxon.id
    },

    initParams() {
      return {
        taxon_name_id: undefined,
        ranks: [],
        validity: false,
        otus: undefined,
        combination: undefined,
        fieldsets: ['observations']
      }
    },

    resetFilter() {
      this.taxonName = undefined
      this.params = this.initParams()
      this.$emit('reset')
    }
  }
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
