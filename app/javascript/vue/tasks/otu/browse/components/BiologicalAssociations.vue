<template>
  <div class="panel content">
    <h3>Biological associations</h3>
    <ul class="no_bullets">
      <li v-for="biologicalAssociation in biologicalAssociations">
        <span v-html="biologicalAssociation.object_tag"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetBiologicalAssociations } from '../request/resources.js'

export default {
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
