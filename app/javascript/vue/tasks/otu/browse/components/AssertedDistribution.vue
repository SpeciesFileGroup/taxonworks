<template>
  <section-panel
    :status="status"
    :spinner="loadState.assertedDistribution"
    :title="title">
    <a
      v-if="currentOtu"
      :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${currentOtu.id}`"
      slot="title">Expand</a>
    <a name="asserted-distributions"/>
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
          <th>type</th>
          <th>Presence/absence</th>
          <th>Shape</th>
          <th>Citations</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="assertedDistribution in assertedDistributions"
          :key="assertedDistribution.id">
          <td>{{ assertedDistribution.geographic_area.name }}</td>
          <td>{{ assertedDistribution.geographic_area.geographic_area_type.name }}</td>
          <td>{{ assertedDistribution.is_absent ? '✕' : '✓' }}</td>
          <td>{{ assertedDistribution.geographic_area.geo_json ? '✓' : '✕' }}</td>
          <td v-html="assertedDistribution.citations.map(citation => citation.citation_source_body).sort().join('; ')"/>
        </tr>
      </tbody>
    </table>
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
