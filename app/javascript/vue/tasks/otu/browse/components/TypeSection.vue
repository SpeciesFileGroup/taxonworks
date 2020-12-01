<template>
  <section-panel
    :status="status"
    :title="title">
    <div class="separate-top">
      <p
        v-if="taxonNameType"
        v-html="taxonNameType"/>
    </div>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import { GetterNames } from '../store/getters/getters'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object
    }
  },
  computed: {
    taxonNameType () {
      const taxon = this.$store.getters[GetterNames.GetTaxonName]
      return taxon && taxon.type_taxon_name_relationship ? taxon.type_taxon_name_relationship.object_tag : undefined
    }
  }
}
</script>
