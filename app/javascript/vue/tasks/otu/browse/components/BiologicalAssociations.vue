<template>
  <section-panel title="Biological associations">
    <ul class="no_bullets">
      <li v-for="biologicalAssociation in biologicalAssociations">
        <span v-html="biologicalAssociation.object_tag"/>
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
    otu(newVal) {
      if(newVal) {
        GetBiologicalAssociations(this.otu.global_id).then(response => {
          this.biologicalAssociations = response.body
        })
      }
    }
  }
}
</script>
