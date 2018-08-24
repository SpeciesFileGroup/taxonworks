<template>
  <div>
    <div class="flex-separate middle">
      <h1 class="task_header"> Nomenclature by source </h1>
      <spinner
        v-if="isLoading"
        :full-screen="true"
        legend="Loading..."
        :logo-size="{ width: '100px', height: '100px'}"/>
      <nomen-source
        @sourceID="sourceID = $event" />
    </div>
      <div class="flexbox">
        <div class="flexbox">
          <h2>Cite a Taxon Name</h2>
          <cite-taxon-name /><br>
          <taxon-names /><br>
          <taxon-name-relationships />
        </div>
      </div>
  </div>

</template>
<script>
  import SmartSelector from './components/smartSelector'
  import NomenSource from './components/nomen_source'
  import CiteTaxonName from './components/cite_taxon_name'
  import TaxonNames from './components/taxon_names'
  import TaxonNameRelationships from './components/taxon_name_relationships'
  import TaxonNameClassifications from './components/taxon_name_classifications'
  import BiologicalRelationships from './components/biological_relationships'
  import AssertedDistributions from './components/asserted_distributions'
  import OtusMatching from './components/otus_matching'
  import OtusByProxy from './components/otus_by_proxy'
  import Spinner from '../../../components/spinner.vue'
  // import AssertedDistributions from './components/asserted_distributions'
  // import AssertedDistributions from './components/asserted_distributions'
  // import AssertedDistributions from './components/asserted_distributions'
  export default {
    components: {
      SmartSelector,
      NomenSource,
      CiteTaxonName,
      TaxonNames,
      TaxonNameRelationships,
      TaxonNameClassifications,
      BiologicalRelationships,
      AssertedDistributions,
      OtusMatching,
      OtusByProxy,
      Spinner
    },
    data() {
      return {
        sourceID: undefined,
        isLoading: false,
        state: false
      }
    },
    // mounted: {
    //
    // }
  }
</script>