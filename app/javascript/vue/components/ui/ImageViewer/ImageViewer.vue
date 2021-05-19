<template>
  <div class="depiction-thumb-container">
    <v-modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? `${depiction.image.width}px` : '500px') )}">
      <h3 slot="header">View</h3>
      <div slot="body">
        <div class="image-container">
          <template>
            <img
              :class="['img-maxsize', this.fullSizeImage ? 'img-fullsize' : 'img-normalsize']"
              @click="fullSizeImage = !fullSizeImage"
              :src="urlSrc"
            >
          </template>
        </div>

        <template v-if="edit">
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
            <div>
              <button
                type="button"
                class="button normal-input button-submit"
                @click="updateDepiction">
                Update
              </button>
            </div>
            <div class="horizontal-left-content">
              <ul class="context-menu no_bullets">
                <li class="horizontal-left-content">
                  <radial-annotator
                    type="annotations"
                    :global-id="depiction.image.global_id"
                    @close="loadData"/>
                  Image
                </li>
                <li class="horizontal-left-content">
                  <radial-annotator
                    type="annotations"
                    :global-id="depiction.global_id"
                    @close="loadData"/>
                  Depiction
                </li>
              </ul>
            </div>
          </div>
        </template>
        <hr>

        <div class="flex-separate">
          <slot name="infoColumn" />
          <div
            v-if="!edit"
            class="full_width panel content">
            <h3>Depiction</h3>
            <ul class="no_bullets">
              <li v-if="depiction.figure_label">
                <span>Label:</span>
                <b v-html="depiction.figure_label"/>
              </li>
              <li v-if="depiction.caption">
                <span>Caption:</span>
                <b v-html="depiction.caption"/>
              </li>
            </ul>
          </div>

          <div
            v-if="attributionsList.length"
            class="full_width panel content margin-small-left">
            <h3>Attributions</h3>
            <template v-for="(attribution, index) in attributionsList">
              <ul
                class="no_bullets"
                :key="index">
                <li
                  v-for="(persons, pIndex) in attribution"
                  :key="pIndex">
                  <span v-html="persons"/>
                </li>
                <li v-if="attributions[index].copyright_year">
                  Copyright year: <b>{{ attributions[index].copyright_year }}</b>
                </li>
                <li v-if="attributions[index].license">
                  License: <b>{{ attributions[index].license }}</b>
                </li>
              </ul>
            </template>
          </div>

          <div
            v-if="originalCitation"
            class="full_width panel content margin-small-left">
            <h3>Original citation</h3>
            <span v-html="originalCitation"/>
          </div>
        </div>
      </div>
    </v-modal>
    <div>
      <div
        class="cursor-pointer"
        @click="viewMode = true">
        <slot>
          <div 
            :class="[`depiction-${thumbSize}-image`]">
            <img
              class="img-thumb"
              :src="thumbUrlSrc"
              :height="depiction.image.alternatives[thumbSize].height"
              :width="depiction.image.alternatives[thumbSize].width">
          </div>
        </slot>
      </div>
      <slot name="thumbfooter" />
    </div>
  </div>
</template>
<script>

import VModal from 'components/ui/Modal.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import { capitalize } from 'helpers/strings.js'
import { Image, Depiction } from 'routes/endpoints'
import { imageSVGViewBox, imageScale } from 'helpers/images'

const CONVERT_IMAGE_TYPES = ['image/tiff']
const ROLE_TYPES = ['creator_roles', 'owner_roles', 'copyright_holder_roles', 'editor_roles']
const roleLabel = (role) => capitalize(role.replace('_roles', '').replaceAll('_', ' '))

const IMG_MAX_SIZES = {
  thumb: 100,
  medium: 300
}

export default {
  components: {
    VModal,
    RadialAnnotator
  },

  props: {
    depiction: {
      type: Object,
      required: true
    },

    edit: {
      type: Boolean,
      default: false
    },

    thumbSize: {
      type: String,
      default: 'thumb'
    }
  },

  computed: {
    attributionsList () {
      return this.attributions.map(attr =>
        ROLE_TYPES.map(role =>
          attr[role] ? `${roleLabel(role)}: <b>${attr[role].map(item => item?.person?.object_tag || item.organization.name).join('; ')}</b>` : []).filter(arr => arr.length))
    },

    originalCitation () {
      return this.citations.filter(citation => citation.is_original).map(citation => [citation.source.cached, citation.pages].filter(item => item).join(':')).join('; ')
    },

    urlSrc () {
      const depiction = this.depiction
      const image = this.image
      const { width, height } = this.image

      return this.hasSVGBox
        ? imageSVGViewBox(depiction.image.id, depiction.svg_view_box, image.width, image.height)
        : CONVERT_IMAGE_TYPES.includes(image.content_type)
          ? imageScale(depiction.image.id, `0 0 ${width} ${height}`, width, height)
          : image.image_file_url
    },

    hasSVGBox () {
      return this.depiction.svg_view_box != null
    },

    thumbUrlSrc () {
      const depiction = this.depiction

      return this.hasSVGBox
        ? imageSVGViewBox(depiction.image.id, depiction.svg_view_box, IMG_MAX_SIZES[this.thumbSize], IMG_MAX_SIZES[this.thumbSize])
        : this.thumbImage.image_file_url
    },

    image () {
      return this.fullSizeImage ? this.depiction.image : this.depiction.image.alternatives.medium
    },

    thumbImage () {
      return this.depiction.image.alternatives[this.thumbSize]
    }
  },

  data () {
    return {
      fullSizeImage: true,
      viewMode: false,
      attributions: [],
      citations: [],
      alreadyLoaded: false
    }
  },

  watch: {
    viewMode (newVal) {
      if (newVal && !this.alreadyLoaded) {
        this.alreadyLoaded = true
        this.loadData(this.depiction.image.id)
      }
    }
  },

  methods: {
    async loadData () {
      const imageId = this.depiction.image.id
      this.attributions = (await Image.attributions(imageId)).body
      this.citations = (await Image.citations(imageId)).body
    },

    updateDepiction () {
      const depiction = {
        caption: this.depiction.caption,
        figure_label: this.depiction.figure_label
      }

      Depiction.update(this.depiction.id, { depiction }).then(() => {
        TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
      })
    }
  }
}
</script>
<style lang="scss">

  .depiction-thumb-image {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100px;
    height: 100px;
    border: 1px solid black;
  }

  .depiction-medium-image {
    display: flex;
    align-items: center;
    justify-content: center;
    max-width: 300px;
    height: 300px;
    border: 1px solid black;
  }

  .depiction-thumb-container {

    margin: 4px;

    .modal-container {
      max-width: 90vw;
      max-height: 90vh;
      overflow: auto;
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
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }
</style>
