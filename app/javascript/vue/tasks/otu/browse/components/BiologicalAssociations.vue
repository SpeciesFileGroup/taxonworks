<template>
  <section-panel
    :status="status"
    :title="title">
    <a name="biological-associations"/>
    <table class="full_width">
      <thead>
        <tr>
          <th>Subject</th>
          <th>Relationship</th>
          <th>Object</th>
          <th>Citations</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="biologicalAssociation in biologicalAssociations"
          :key="biologicalAssociation.id">
          <td v-html="biologicalAssociation.subject.object_tag"/>
          <td v-html="biologicalAssociation.biological_relationship.object_tag"/>
          <td v-html="biologicalAssociation.object.object_tag"/>
          <td>
            {{ biologicalAssociation.citations.map(citation => citation.citation_source_body).join('; ') }}
          </td>
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
    biologicalAssociations () {
      return this.$store.getters[GetterNames.GetBiologicalAssociations]
    }
  }
}
</script>
