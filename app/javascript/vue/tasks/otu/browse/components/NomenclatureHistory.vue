<template>
  <div class="panel content">
    <h3>Nomenclature</h3>
    <div v-html="nomenclatureHtml"/>
  </div>
</template>

<script>

import { GetNomenclatureHistory } from '../request/resources.js'

export default {
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      nomenclatureHtml: ''
    }
  },
  watch: {
    otu(newVal) {
      GetNomenclatureHistory(this.otu.taxon_name_id).then(response => {
        this.nomenclatureHtml = response.body.html
      })
    }
  }
}
</script>
