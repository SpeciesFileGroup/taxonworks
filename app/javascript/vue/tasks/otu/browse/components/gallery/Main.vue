<template>
  <section-panel
    :status="status"
    :title="title">
    <div
      class="flex-wrap-row"
      v-if="figuresList.length"
    >
      <image-viewer
        v-for="item in figuresList"
        :key="item.id"
        :depiction="item"
        edit
      />
    </div>
  </section-panel>
</template>

<script>

import ImageViewer from 'components/ui/ImageViewer/ImageViewer'
import SectionPanel from '../shared/sectionPanel'
import extendSection from '../shared/extendSections'
import { GetterNames } from '../../store/getters/getters'

export default {
  mixins: [extendSection],
  components: {
    ImageViewer,
    SectionPanel
  },
  computed: {
    figuresList () {
      return this.$store.getters[GetterNames.GetDepictions]
    }
  }
}
</script>
