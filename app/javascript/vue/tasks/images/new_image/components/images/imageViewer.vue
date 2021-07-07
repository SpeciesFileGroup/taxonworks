<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? image.width : image.alternatives.medium.width) + 'px')}">
      <template #header>
        <h3>Image viewer</h3>
      </template>
      <template #body>
        <div>
          <img
            class="img-maxsize img-fullsize"
            v-if="fullSizeImage"
            @click="fullSizeImage = false"
            :src="image.image_file_url"
            :height="image.height"
            :width="image.width">
          <img
            v-else
            class="img-maxsize img-normalsize"
            @click="fullSizeImage = true"
            :src="image.alternatives.medium.image_file_url"
            :height="image.alternatives.medium.height"
            :width="image.alternatives.medium.width">
          <div class="flex-separate">
            <button
              type="button"
              @click="deleteImage"
              class="normal-input button button-delete">Delete</button>
          </div>
        </div>
      </template>
    </modal>
    <img
      class="img-thumb"
      @click="viewMode = true"
      :src="image.alternatives.thumb.image_file_url"
      :height="image.alternatives.thumb.height"
      :width="image.alternatives.thumb.width">
    <div class="flex-separate">
      <radial-annotator
        type="annotations"
        :global-id="image.global_id"/>
      <radial-object :global-id="image.global_id"/>
      <span
        class="circle-button btn-delete"
        @click="deleteImage"/>
    </div>
  </div>
</template>
<script>

import Modal from 'components/ui/Modal.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'

export default {
  components: {
    Modal,
    RadialAnnotator,
    RadialObject
  },

  props: {
    image: {
      type: Object,
      required: true
    }
  },

  emits: ['delete'],

  data () {
    return {
      fullSizeImage: false,
      viewMode: false
    }
  },

  methods: {
    deleteImage () {
      if (window.confirm('Are you sure you want to delete this image?')) {
        this.$emit('delete', this.image)
      }
    }
  }
}
</script>
<style lang="scss">
  .depiction-thumb-container {
    margin: 4px;
    .img-thumb {
      cursor: pointer;
    }
    .img-maxsize {
      transition: all 0.5s ease;
      max-width: 100%;
      max-height: 60vh;
    }
    .img-fullsize {
      cursor: zoom-out
    }
    .img-normalsize {
      cursor: zoom-in
    }
    .field {
      input, textarea {
        width: 100%
      }
    }
  }
</style>
