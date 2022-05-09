<template>
  <div id="nomenclature-by-source-task">
    <div>
      <div class="flex-separate middle">
        <h1 class="task_header">Citations by source</h1>
        <a href="/tasks/sources/hub">Back to source hub</a>
      </div>
      <nomen-source />
    </div>
    <div class="flexbox">
      <div class="flexbox">
        <div class="first-column separate-right">
          <CitationTaxonName />
          <CitationRelationships />
          <CitationClassification />
          <CitationBiologicalAssociation />
          <CitationAssertedDistribution />
          <CitationOtu />
        </div>
        <div class="second-column separate-left">
          <otus-match-proxy />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: 'CitationsBySource',
}
</script>
<script setup>

import NomenSource from './components/nomen_source'
import CitationOtu from './components/Citation/CitationOtu.vue'
import CitationTaxonName from './components/Citation/CitationTaxonName.vue'
import CitationRelationships from './components/Citation/CitationRelationship.vue'
import CitationClassification from './components/Citation/CitationClassification.vue'
import CitationBiologicalAssociation from './components/Citation/CitationBiologicalAssociation.vue'
import CitationAssertedDistribution from './components/Citation/CitationAssertedDistribution.vue'
import OtusMatchProxy from './components/otus_match_proxy'

</script>

<style lang="scss">
  #nomenclature-by-source-task {
    table {
      width: 100%;
      max-width: 800px;
    }
  }
</style>
