<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? depiction.image.width : depiction.image.alternatives.medium.width) + 'px')}">
      <h3 slot="header">View</h3>
      <div slot="body">
        <template>
          <img
            class="img-maxsize img-fullsize"
            v-if="fullSizeImage"
            @click="fullSizeImage = false"
            :src="depiction.image.image_file_url"
            :height="depiction.image.height"
            :width="depiction.image.width">
          <img
            v-else
            class="img-maxsize img-normalsize"
            @click="fullSizeImage = true"
            :src="depiction.image.alternatives.medium.image_file_url"
            :height="depiction.image.alternatives.medium.height"
            :width="depiction.image.alternatives.medium.width">
        </template>
        <div class="field separate-top">
          <input
            v-model="depiction.figure_label"
            type="text"
            placeholder="Label">
        </div>
        <div class="field separate-bottom">
          <textarea
            v-model="depiction.caption"
            rows="5"
            placeholder="Caption"/>
        </div>
        <div class="flex-separate">
          <button
            type="button"
            @click="updateDepiction"
            class="normal-input button button-submit">Update</button>
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
      :src="depiction.image.alternatives.thumb.image_file_url"
      :height="depiction.image.alternatives.thumb.height"
      :width="depiction.image.alternatives.thumb.width">
    <div class="horizontal-left-content">
      <radial-annotator
        type="annotations"
        :global-id="depiction.image.global_id"/>
      <radial-annotator
        type="annotations"
        :global-id="depiction.global_id"/>
      <span
        class="circle-button btn-delete"
        @click="deleteDepiction"/>
    </div>
  </div>
</template>
<script>

import Modal from 'components/modal.vue'
import { UpdateDepiction } from '../request/resources'
import RadialAnnotator from 'components/annotator/annotator'

export default {
  components: {
    Modal,
    RadialAnnotator
  },
  props: {
    depiction: {
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
    updateDepiction () {
      let depiction = {
        depiction: {
          caption: this.depiction.caption,
          figure_label: this.depiction.figure_label
        }
      }
      UpdateDepiction(this.depiction.id, depiction).then(response => {
        TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
      })
    },
    deleteDepiction () {
      this.$emit('delete', this.depiction)
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
