<template>
  <div class="panel content">
    <h3>Asserted distributions</h3>
    <ul class="no_bullets">
      <li v-for="assertedDistribution in assertedDistributions">
        <span v-html="assertedDistribution.geographic_area.name"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetAssertedDistributions } from '../request/resources.js'

export default {
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
    otu(newVal) {
      if(newVal) {
        GetAssertedDistributions(newVal.id).then(response => {
          this.assertedDistributions = response.body
        })
      }
    }
  }
}
</script>
