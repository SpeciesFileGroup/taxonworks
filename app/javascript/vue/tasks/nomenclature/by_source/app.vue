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
      <nomen-source @sourceID="lists = initStoreList(); sourceID = $event"/>
    </div>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column separate-right">
          <taxon-names
            :sourceID="sourceID"
            :newTaxon="newTaxonNameCitation"
            @summarize="summarize = $event"
          />
          <taxon-name-relationships
            :sourceID="sourceID"
            @summarize="summarize = $event"
          />
          <taxon-name-classifications
            :sourceID="sourceID"
            @summarize="summarize = $event"
          />
          <biological-associations
            :sourceID="sourceID"
            @summarize="summarize = $event"
          />
          <asserted-distributions
            :sourceID="sourceID"
            @summarize="summarize = $event"
          />
          <otus-by-match
            :sourceID="sourceID"
            @summarize="summarize = $event"
          />
        </div>
        <div class="second-column separate-left">
          <otus-match-proxy
            :sourceID="sourceID"
            :summarize="summarize"
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
        lists: this.initStoreList(),
        summarize: undefined
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
