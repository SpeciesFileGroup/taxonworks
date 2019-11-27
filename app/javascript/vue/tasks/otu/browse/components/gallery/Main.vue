<template>
    <section-panel title="Images">
      <div
        class="flex-wrap-row"
        v-if="figuresList.length">
        <image-viewer
          v-for="item in figuresList"
          :key="item.id"
          :depiction="item"/>
      </div>
    </section-panel>
</template>

<script>

import { GetDepictions } from '../../request/resources.js'

import ImageViewer from './ImageViewer'
import SectionPanel from '../shared/sectionPanel'

export default {
  components: {
    ImageViewer,
    SectionPanel
  },
  props: {
    otu: {
      type: Object
    }
  },
  data: function () {
    return {
      figuresList: []
    }
  },
  watch: {
    otu: { 
      handler (newVal, oldVal) {
        if (newVal) {
          GetDepictions('otus', newVal.id).then(response => {
            this.figuresList = response.body
          })
        }
      }, 
      immediate: true
    }
  }
}
</script>

