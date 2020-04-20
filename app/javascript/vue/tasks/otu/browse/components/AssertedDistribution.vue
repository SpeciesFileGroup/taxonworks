<template>
  <section-panel title="Asserted distributions">
    <a
      :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${otu.id}`"
      slot="title">Expand</a>
    <a name="asserted-distributions"/>
    <ul class="no_bullets">
      <li v-for="assertedDistribution in assertedDistributions">
        <span v-html="assertedDistribution.geographic_area.name"/>
      </li>
    </ul>
  </section-panel>
</template>

<script>

import { GetAssertedDistributions } from '../request/resources.js'
import SectionPanel from './shared/sectionPanel'

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
      assertedDistributions: []
    }
  },
  watch: {
    otu: { 
      handler (newVal) {
        if(newVal) {
          GetAssertedDistributions(newVal.id).then(response => {
            this.assertedDistributions = response.body
          })
        }
      },
      immediate: true
    }
  }
}
</script>
