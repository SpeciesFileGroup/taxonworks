<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="checkEdit"
      :container-style="{ width: ((fullSizeImage ? depiction.image.width : depiction.image.alternatives.medium.width) + 'px')}">
      <h3 slot="header">View</h3>
      <div slot="body">
        <template>
          <div class="img-box">
            <img
              class="img-maxsize img-fullsize"
              v-if="fullSizeImage"
              @click="fullSizeImage = false"
              :src="depiction.svg_view_box != null ? 
                getImageUrl(depiction.image.id, depiction.svg_view_box, depiction.image.width, depiction.image.height) : 
                depiction.image.image_display_url"
              :height="depiction.image.height"
              :width="depiction.image.width">
            <img
              v-else
              class="img-maxsize img-normalsize"
              @click="fullSizeImage = true"
              :src="depiction.svg_view_box != null ? 
                getImageUrl(depiction.image.id, depiction.svg_view_box, depiction.image.alternatives.medium.width, depiction.image.alternatives.medium.height) : 
                depiction.image.alternatives.medium.image_file_url">
            <radial-annotator
              class="annotator"
              type="annotations"
              :global-id="depiction.image.global_id"/>
          </div>
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
      :src="depiction.svg_view_box != null ? 
        getImageUrl(depiction.image.id, depiction.svg_view_box, 100, 100) : 
        depiction.image.alternatives.thumb.image_file_url">
  </div>
</template>
<script>

import Modal from 'components/modal.vue'
import { UpdateDepiction } from '../../request/resources'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'

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
      viewMode: false,
      editing: false
    }
  },
  watch: {
    viewMode(newVal) {
      if(newVal) {
        this.editing = false
      }
    },
    depiction: {
      handler(newVal) {
        this.editing = true
      },
      deep: true
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
        this.editing = false
      })
    },
    deleteDepiction () {
      this.$emit('delete', this.depiction)
    },
    checkEdit() {
      if(this.editing) {
        if(window.confirm('You have unsaved changes and they will be lost. Are you sure you want to close?')) {
          this.viewMode = false
        }
      } else {
        this.viewMode = false
      }
    },
    getImageUrl (id, box, imageWidth, imageHeight) {
      let [ x, y, width, height ] = box.split(' ')
      return `/images/${id}/scale_to_box/${Math.floor(x)}/${Math.floor(y)}/${Math.floor(width)}/${Math.floor(height)}/${imageWidth}/${imageHeight}`
    },
    getImageDepictionUrl () {
      let x = 0
      let y = 0
      let width = this.depiction.image.width
      let height = this.depiction.image.height
      let imageWidth = Math.floor(this.windowWidth()*0.75)
      let imageHeight = this.windowHeight()
      return `/images/${this.depiction.image.id}/scale_to_box/${Math.floor(x)}/${Math.floor(y)}/${Math.floor(width)}/${Math.floor(height)}/${imageWidth}/${imageHeight}`
    },
    windowWidth () {
      return window.innerWidth
    },
    windowHeight () {
      return (window.innerHeight * 0.40) < 400 ? Math.floor(window.innerHeight * 0.40) : 400
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
    .img-box {
      position: relative;
    }
    .annotator {
      position: absolute;
      right: 10px;
      top: 10px;
    }

  }
</style>
