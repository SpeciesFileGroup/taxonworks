<template>
  <div id="nomenclature-by-source-task">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div>
      <h1 class="task_header">Citations by source</h1>
      <nomen-source @sourceID="lists = initStoreList(); sourceID = $event"/>
    </div>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column separate-right">
          <taxon-names
            :sourceID="sourceID"
            :newTaxon="newTaxonNameCitation"
            @taxon_names_cites="lists.taxon_names_cites=$event"
          />
          <cite-taxon-name
            :sourceID="sourceID"
            :cite-taxon-list="lists.taxon_names_cites"
            @foundTaxon="newTaxonNameCitation=$event"
          />
          <taxon-name-relationships
            :sourceID="sourceID"
            @taxon_relationship_cites="lists.taxon_relationship_cites=$event"
          />
          <taxon-name-classifications
            :sourceID="sourceID"
            @taxon_classification_cites="lists.taxon_classification_cites=$event"
          />
          <biological-associations
            :sourceID="sourceID"
            @biological_association_cites="lists.biological_association_cites=$event"
          />
          <asserted-distributions
            :sourceID="sourceID"
            @distribution_cites="lists.distribution_cites=$event"
          />
          <otus-by-match
            :sourceID="sourceID"
            @otu_names_cites="lists.otu_names_cites=$event"
          />
        </div>
        <div class="second-column separate-left">
          <otus-match-proxy
            :sourceID="sourceID"
            :otu_names_cites="lists.otu_names_cites"
            :taxon_names_cites="lists.taxon_names_cites"
            :taxon_relationship_cites="lists.taxon_relationship_cites"
            :taxon_classification_cites="lists.taxon_classification_cites"
            :biological_association_cites="lists.biological_association_cites"
            :distribution_cites="lists.distribution_cites"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>

  import NomenSource from './components/nomen_source'
  import CiteTaxonName from './components/cite_taxon_name'
  import OtusByMatch from './components/otus_by_match'
  import TaxonNames from './components/taxon_names'
  import TaxonNameRelationships from './components/taxon_name_relationships'
  import TaxonNameClassifications from './components/taxon_name_classifications'
  import BiologicalAssociations from './components/biological_associations'
  import AssertedDistributions from './components/asserted_distributions'
  import OtusMatchProxy from './components/otus_match_proxy'
  import Spinner from 'components/spinner.vue'

  export default {
    components: {
      NomenSource,
      OtusByMatch,
      CiteTaxonName,
      TaxonNames,
      TaxonNameRelationships,
      TaxonNameClassifications,
      BiologicalAssociations,
      AssertedDistributions,
      OtusMatchProxy,
      Spinner
    },
    data() {
      return {
        sourceID: undefined,
        isLoading: false,
        newTaxonNameCitation: {},
        lists: this.initStoreList()
      }
    },
    methods: {
      enableButton() {
        this.updateOtus = true;
      },
      initStoreList() {
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
