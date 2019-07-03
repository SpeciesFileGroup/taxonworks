<template>
  <div>
    <img
      :src="depiction.image.alternatives.thumb.image_file_url"
      :width="depiction.image.alternatives.thumb.width"
      :height="depiction.image.alternatives.thumb.height"
      :key="depiction.id">
    <div class="horizontal-left-content">
      <radial-annotator :global-id="depiction.global_id"/>
      <span class="circle-button btn-delete"/>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    depiction: {
      type: Object,
      required: true
    }
  }
}
</script>

<style>

</style>
