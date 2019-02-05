<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? image.width : image.alternatives.medium.width) + 'px')}">
      <h3 slot="header">Image viewer</h3>
      <div slot="body">
        <template>
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
        </template>
        <div class="flex-separate">
          <button
            type="button"
            @click="deleteDepiction"
            class="normal-input button button-delete">Delete</button>
        </div>
      </div>
    </modal>
    <img
      class="img-thumb"
      @click="viewMode = true"
      :src="image.alternatives.thumb.image_file_url"
      :height="image.alternatives.thumb.height"
      :width="image.alternatives.thumb.width">
  </div>
</template>
<script>

import Modal from 'components/modal.vue'

export default {
  components: {
    Modal
  },
  props: {
    image: {
      type: Object,
      required: true
    }
  },
  data: function () {
    return {
      fullSizeImage: false,
      viewMode: false
    }
  },
  methods: {
    deleteDepiction () {
      this.$emit('delete', this.image)
    }
  }
}
</script>
<style lang="scss">
  .depiction-thumb-container {
    .modal-container {
      max-width: 100vh;
    }
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
