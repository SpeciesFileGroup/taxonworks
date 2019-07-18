<template>
  <div>
    <img
      :src="depiction.image.alternatives.thumb.image_file_url"
      :width="depiction.image.alternatives.thumb.width"
      :height="depiction.image.alternatives.thumb.height"
      :key="depiction.id"
      @click="showModal = true">
    <depiction-modal-viewer
      v-if="showModal"
      :depiction="depiction"
      @close="showModal = false"/>
    <div class="horizontal-left-content">
      <radial-annotator :global-id="depiction.global_id"/>
      <span
        class="circle-button btn-delete"
        @click="removeDepiction"/>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'
import DepictionModalViewer from 'components/depictionModalViewer/depictionModalViewer.vue'

export default {
  components: {
    RadialAnnotator,
    DepictionModalViewer
  },
  props: {
    depiction: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showModal: false
    }
  },
  methods: {
    removeDepiction() {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', this.depiction)
      }
    }
  }
}
</script>

<style>

</style>
