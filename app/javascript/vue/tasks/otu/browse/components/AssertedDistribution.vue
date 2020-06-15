<template>
  <section-panel title="Asserted distributions">
    <a
      v-if="currentOtu"
      :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${currentOtu.id}`"
      slot="title">Expand</a>
    <a name="asserted-distributions"/>
    <ul class="no_bullets">
      <li
        v-for="assertedDistribution in assertedDistributions"
        :key="assertedDistribution.id">
        <span v-html="assertedDistribution.geographic_area.name"/>
      </li>
    </ul>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    SectionPanel
  },
  computed: {
    assertedDistributions () {
      return this.$store.getters[GetterNames.GetAssertedDistributions]
    },
    currentOtu () {
      return this.$store.getters[GetterNames.GetCurrentOtu]
    }
  }
}
</script>
