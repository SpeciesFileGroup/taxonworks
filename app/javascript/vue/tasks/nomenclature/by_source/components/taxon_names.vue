<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>Taxon names</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !taxon_names_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <taxon-names-table
      :list="taxon_names_cites_list"
    />
  </div>
</template>
<script>

import TaxonNamesTable from './tables/taxon_names_table.vue'
import SpinnerComponent from 'components/spinner.vue'
import { Citation, TaxonName } from 'routes/endpoints'
import { chunkArray } from 'helpers/arrays'
import { TAXON_NAME } from 'constants/index.js'

const MAX_PER_REQUEST = 25

export default {
  components: {
    TaxonNamesTable,
    SpinnerComponent
  },

  props: {
    sourceID: {
      type: String,
      default: undefined
    },

    newTaxon: {
      type: Object,
      default: () => ({})
    }
  },

  emits: [
    'taxon_names_cites',
    'summarize'
  ],

  data () {
    return {
      taxon_names_cites_list: [],
      showSpinner: false
    }
  },

  watch: {
    sourceID () {
      this.getCites()
    },

    newTaxon () {
      this.addToList(this.newTaxon)
    }
  },

  methods: {
    getCites () {
      const params = {
        citation_object_type: TAXON_NAME,
        source_id: this.sourceID
      }

      this.showSpinner = true

      Citation.where(params).then(({ body }) => {
        const arrIds = chunkArray(body.map(item => item.citation_object_id), MAX_PER_REQUEST)
        const requestTaxons = arrIds.map(ids => TaxonName.where({ taxon_name_id: ids }))

        Promise.all(requestTaxons).then(responses => {
          const taxonList = [].concat(...responses.map(r => r.body))

          this.taxon_names_cites_list = body.map(item => ({
            ...item,
            citation_object: taxonList.find(taxon => taxon.id === item.citation_object_id)
          }))
        }).finally(_ => {
          this.showSpinner = false
        })
      })
    },

    addToList (citation) {
      this.taxon_names_cites_list.push(citation)
      this.$emit('taxon_names_cites', this.taxon_names_cites_list)
    },

    summarize () {
      this.$emit('summarize', {
        type: 'taxon_name_ids',
        list: this.taxon_names_cites_list
      })
    }
  },
}
</script>