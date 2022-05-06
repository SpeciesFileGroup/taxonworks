<template>
  <div id="nomenclature-by-source-task">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div>
      <div class="flex-separate middle">
        <h1 class="task_header">Citations by source</h1>
        <a href="/tasks/sources/hub">Back to source hub</a>
      </div>
      <nomen-source @sourceId="lists = initStoreList(); sourceId = $event"/>
    </div>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column separate-right">
          <CitationTaxonName :sourceId="sourceId" />
          <taxon-name-relationships
            :sourceId="sourceId"
            @summarize="summarize = $event"
          />
          <taxon-name-classifications
            :sourceId="sourceId"
            @summarize="summarize = $event"
          />
          <biological-associations
            :sourceId="sourceId"
            @summarize="summarize = $event"
          />
          <CitationAssertedDistribution :source-id="sourceId" />
          <otus-by-match
            :sourceId="sourceId"
            @summarize="summarize = $event"
          />
        </div>
        <div class="second-column separate-left">
          <otus-match-proxy
            :sourceId="sourceId"
            :summarize="summarize"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>

import NomenSource from './components/nomen_source'
import OtusByMatch from './components/otus_by_match'
import CitationTaxonName from './components/Citation/CitationTaxonName.vue'
import TaxonNameRelationships from './components/taxon_name_relationships'
import TaxonNameClassifications from './components/taxon_name_classifications'
import BiologicalAssociations from './components/biological_associations'
import CitationAssertedDistribution from './components/Citation/CitationAssertedDistribution.vue'
import OtusMatchProxy from './components/otus_match_proxy'
import Spinner from 'components/spinner.vue'

export default {
  name: 'CitationsBySource',

  components: {
    NomenSource,
    OtusByMatch,
    CitationTaxonName,
    TaxonNameRelationships,
    TaxonNameClassifications,
    BiologicalAssociations,
    CitationAssertedDistribution,
    OtusMatchProxy,
    Spinner
  },

  data () {
    return {
      sourceId: undefined,
      isLoading: false,
      lists: this.initStoreList(),
      summarize: undefined
    }
  },

  methods: {
    enableButton () {
      this.updateOtus = true
    },

    initStoreList () {
      return {
        otu_names_cites: [],
        taxon_names_cites: [],
        taxon_relationship_cites: [],
        taxon_classification_cites: [],
        biological_association_cites: [],
        distribution_cites: [],
      }
    }
  }
}
</script>

<style lang="scss">
  #nomenclature-by-source-task {
    table {
      width: 100%;
      max-width: 800px;
    }
  }
</style>
