<template>
  <div class="depiction-viewer-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? depiction.image.width : depiction.image.alternatives.medium.width) + 'px')}">
      <h3 slot="header">View</h3>
      <div slot="body">
        <div class="image-container">
          <template>
            <img
              class="img-maxsize img-fullsize"
              v-if="fullSizeImage"
              @click="fullSizeImage = false"
              :src="depiction.image.image_file_url">
            <img
              v-else
              class="img-maxsize img-normalsize"
              @click="fullSizeImage = true"
              :src="depiction.image.alternatives.medium.image_file_url"
              :height="depiction.image.alternatives.medium.height"
              :width="depiction.image.alternatives.medium.width">
          </template>
        </div>
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
        v-if="radialImage"
        :global-id="depiction.image.global_id"/>
      <radial-annotator
        type="annotations"
        v-if="radialDepiction"
        :global-id="depiction.global_id"/>
      <default-citation
        :is-original="isOriginal"
        :citations="depiction.image.citations"
        :global-id="depiction.image.global_id"/>
      <span
        class="circle-button btn-delete"
        @click="deleteDepiction"/>
    </div>
  </div>
</template>
<script>

import Modal from 'components/modal.vue'
import { UpdateDepiction } from './request/resources'
import RadialAnnotator from 'components/radials/annotator/annotator'
import DefaultCitation from 'components/defaultCitation'

export default {
  components: {
    Modal,
    RadialAnnotator,
    DefaultCitation
  },
  props: {
    depiction: {
      type: Object,
      required: true
    },
    radialDepiction: {
      type: Boolean,
      default: false
    },
    radialImage: {
      type: Boolean,
      default: true
    },
    isOriginal: {
      type: Boolean,
      default: false
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
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', this.depiction)
      }
    }
  }
}
</script>
<style lang="scss" scoped>
  .depiction-viewer-thumb-container {
    .modal-container {
      max-width: 100vh;
    }
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

    .image-container {
      display: flex;
      justify-content: center;
      background-color: black;
    }
  }
</style>
