<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>OTUs</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !otu_names_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component :list="otu_names_cites_list"/>
  </div>
</template>
<script>

import SpinnerComponent from 'components/spinner.vue'
import TableComponent from './tables/table.vue'
import extend from '../const/extendRequest.js'
import { Citation } from 'routes/endpoints'

export default {
  components: {
    TableComponent,
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

  emits: ['summarize'],

  data () {
    return {
      otu_names_cites_list: [],
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
        citation_object_type: 'Otu',
        source_id: this.sourceID,
        extend
      }

      this.showSpinner = true

      Citation.where(params).then(response => {
        this.showSpinner = false
        this.otu_names_cites_list = response.body
      })
    },

    addToList (citation) {
      this.otu_names_cites_list.push(citation)
    },

    summarize () {
      this.$emit('summarize', {
        type: 'otu_ids',
        list: this.otu_names_cites_list
      })
    }
  },
}
</script>