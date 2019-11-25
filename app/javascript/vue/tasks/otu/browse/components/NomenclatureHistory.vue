<template>
  <section-panel title="Nomenclature">
    <div v-html="nomenclatureHtml"/>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetNomenclatureHistory } from '../request/resources.js'

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
      nomenclatureHtml: ''
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal && newVal.taxon_name_id) {
          GetNomenclatureHistory(this.otu.taxon_name_id).then(response => {
            this.nomenclatureHtml = response.body.html
          })
        }
      },
      immediate: true
    }
  }
}
</script>
