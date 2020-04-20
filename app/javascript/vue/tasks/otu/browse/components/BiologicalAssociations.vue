<template>
  <section-panel title="Biological associations">
    <a name="biological-associations"/>
    <ul class="no_bullets">
      <li v-for="biologicalAssociation in biologicalAssociations">
        <a
          :href="`/biological_associations/${biologicalAssociation.id}`"
          v-html="biologicalAssociation.object_tag"/>
      </li>
    </ul>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetBiologicalAssociations } from '../request/resources.js'

export default {
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      biologicalAssociations: []
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal) {
          GetBiologicalAssociations(this.otu.global_id).then(response => {
            this.biologicalAssociations = response.body
          })
        }
      },
      immediate: true
    }
  }
}
</script>
