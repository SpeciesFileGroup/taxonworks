<template>
  <section-panel title="Specimen records">
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetCollectionObjects } from '../request/resources'

export default {
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      collectionObjects: []
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal) {
          GetCollectionObjects([newVal.id]).then(response => {
            this.collectionObjects = response.body
          })
        }
      },
      immediate: true
    }
  },
  mounted () {

  }
}
</script>