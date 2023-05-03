<template>
  <div id="nomenclature-by-source-task">
    <div class="flex-separate middle">
      <h1>Citations by source</h1>
      <ul class="context-menu">
        <li>
          <SourcePicker />
        </li>
        <li>
          <a href="/tasks/sources/hub">Back to source hub</a>
        </li>
      </ul>
    </div>

    <HeaderBar />

    <div class="flexbox">
      <div class="margin-small-right">
        <template
          v-for="({ title, summarizeParam }, type) in CITATION_BLOCKS"
          :key="type"
        >
          <CitationSummary
            :title="title"
            :summarize-param="summarizeParam"
            :type="type"
          />
        </template>
      </div>
      <OtusMatchProxy class="margin-small-left" />
    </div>
  </div>
</template>

<script setup>

import HeaderBar from './components/HeaderBar.vue'
import CitationSummary from './components/CitationSummary.vue'
import OtusMatchProxy from './components/OtusMatchProxy'
import SourcePicker from './components/SourcePicker.vue'
import {
  TAXON_NAME,
  TAXON_NAME_RELATIONSHIP,
  TAXON_NAME_CLASSIFICATION,
  BIOLOGICAL_ASSOCIATION,
  ASSERTED_DISTRIBUTION,
  OTU
} from 'constants/index.js'

const CITATION_BLOCKS = {
  [TAXON_NAME]: {
    title: 'Taxon names',
    summarizeParam: 'taxon_name_ids'
  },
  [TAXON_NAME_CLASSIFICATION]: {
    title: 'Nomenclature status',
    summarizeParam: 'taxon_name_classification_ids'
  },
  [TAXON_NAME_RELATIONSHIP]: {
    title: 'Taxon name relationships',
    summarizeParam: 'taxon_name_relationship_ids'
  },
  [BIOLOGICAL_ASSOCIATION]: {
    title: 'Biological associations',
    summarizeParam: 'biological_association_ids'
  },
  [ASSERTED_DISTRIBUTION]: {
    title: 'Asserted distributions',
    summarizeParam: 'asserted_distribution_ids'
  },
  [OTU]: {
    title: 'OTUs',
    summarizeParam: 'otu_ids'
  }
}

</script>

<script>
export default {
  name: 'CitationsBySource'
}
</script>
