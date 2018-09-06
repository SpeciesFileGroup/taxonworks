<template>
  <div>
    <div class="flexbox">
      <h1 class="task_header"> Nomenclature by source </h1>
      <spinner
          v-if="isLoading"
          :full-screen="true"
          legend="Loading..."
          :logo-size="{ width: '100px', height: '100px'}"/>
      <nomen-source @sourceID="sourceID = $event"/>
    </div>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column">
          <cite-taxon-name
            :sourceID="sourceID"
            @foundTaxon="newTaxonNameCitation=$event"
          />
          <taxon-names
            :sourceID="sourceID"
            :newTaxon="newTaxonNameCitation"
            @taxon_names_cites="taxon_names_cites=$event"
          />
          <taxon-name-relationships
            :sourceID="sourceID"
            @taxon_relationship_cites="taxon_relationship_cites=$event"
          />
          <taxon-name-classifications
            :sourceID="sourceID"
            @taxon_classification_cites="taxon_classification_cites=$event"
          />
          <biological-associations
            :sourceID="sourceID"
            @biological_association_cites="biological_association_cites=$event"
          />
          <asserted-distributions
            :sourceID="sourceID"
            @distribution_cites="distribution_cites=$event"
          />
        </div>
        <div class="second-column">
          <otus-match-proxy
            :sourceID="sourceID"
            :taxon_names_cites="taxon_names_cites"
            :taxon_relationship_cites="taxon_relationship_cites"
            :taxon_classification_cites="taxon_classification_cites"
            :biological_association_cites="biological_association_cites"
            :distribution_cites="distribution_cites"
            :updateOtus="updateOtus"
            @updateEnd="updateOtus=false"
          />
        </div>
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
  import BiologicalAssociations from './components/biological_associations'
  import AssertedDistributions from './components/asserted_distributions'
  import OtusMatchProxy from './components/otus_match_proxy'
  import Spinner from '../../../components/spinner.vue'
  // import  from './components/asserted_distributions'
  // import AssertedDistributions from './components/asserted_distributions'
  export default {
    components: {
      SmartSelector,
      NomenSource,
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
        taxon_names_cites: [],
        taxon_relationship_cites: [],
        taxon_classification_cites: [],
        biological_association_cites: [],
        distribution_cites: [],
        updateOtus: false
      }
    },
    watch: {
      taxon_names_cites() {
        this.updateOtus = true
      },
      taxon_relationship_cites() {
        this.updateOtus = true
      },
      taxon_classification_cites() {
        this.updateOtus = true
      },
      biological_association_cites() {
        this.updateOtus = true
      },
      distribution_cites() {
        this.updateOtus = true
      }
    },
    methods: {
      enableButton() {
        this.updateOtus = true;
      }
    }
    // mounted: {
    //
    // }
  }
</script>