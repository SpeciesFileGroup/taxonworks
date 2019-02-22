<template>
  <div class="panel depiction-container content">
    <div
      class="flex-wrap-row "
      v-if="figuresList.length">
      <image-viewer
        v-for="item in figuresList"
        :key="item.id"
        :depiction="item"/>
    </div>
  </div>
</template>

<script>

import { GetDepictions } from '../../request/resources.js'

import ImageViewer from './ImageViewer'

export default {
  components: {
    ImageViewer
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
    otu (newVal, oldVal) {
      if (newVal) {
        GetDepictions(newVal.id).then(response => {
          this.figuresList = response.body
        })
      }
    }
  }
}
</script>

