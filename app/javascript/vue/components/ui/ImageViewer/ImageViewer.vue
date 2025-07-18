<template>
  <div class="depiction-thumb-container">
    <VModal
      v-if="isModalVisible"
      class="depiction-modal-container"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>View</h3>
      </template>
      <template #body>
        <div class="image-container margin-medium-bottom">
          <SvgViewer
            v-if="svgClip"
            class="img-maxsize full_width"
            :height="depiction.image.height"
            :groups="svgClip"
            :image="{
              url: originalImageUrl,
              width: depiction.image.width,
              height: depiction.image.height
            }"
          />
          <img
            v-else
            class="img-maxsize"
            @click="state.fullSizeImage = !state.fullSizeImage"
            :src="urlSrc"
          />
        </div>

        <template v-if="edit">
          <div v-if="depiction">
            <div class="field separate-top">
              <input
                v-model="depiction.figure_label"
                type="text"
                placeholder="Label"
              />
            </div>
            <div class="field separate-bottom">
              <textarea
                v-model="depiction.caption"
                rows="5"
                placeholder="Caption"
              />
            </div>
          </div>
          <div class="flex-separate">
            <div>
              <button
                v-if="depiction"
                type="button"
                class="button normal-input button-submit"
                @click="updateDepiction"
              >
                Update
              </button>
            </div>
            <div class="horizontal-left-content">
              <div class="horizontal-left-content">
                <span class="margin-small-right">Image</span>
                <div class="square-brackets">
                  <ul class="context-menu no_bullets">
                    <li>
                      <v-btn
                        circle
                        color="primary"
                        @click="openFullsize"
                      >
                        <v-icon
                          x-small
                          name="expand"
                          color="white"
                        />
                      </v-btn>
                    </li>
                    <li>
                      <v-btn
                        circle
                        :href="image.image_file_url"
                        :download="image.image_original_filename"
                        color="primary"
                      >
                        <v-icon
                          x-small
                          name="download"
                          color="white"
                        />
                      </v-btn>
                    </li>
                    <li>
                      <radial-annotator
                        type="annotations"
                        :global-id="imageObject.global_id"
                      />
                    </li>
                    <li>
                      <radial-navigation :global-id="imageObject.global_id" />
                    </li>
                  </ul>
                </div>
              </div>

              <div
                v-if="depiction?.global_id"
                class="horizontal-left-content margin-large-left"
              >
                <span class="margin-small-right">Depiction</span>
                <div class="square-brackets">
                  <ul class="context-menu no_bullets">
                    <li>
                      <radial-annotator
                        type="annotations"
                        :global-id="depiction.global_id"
                      />
                    </li>
                    <li>
                      <radial-navigation :global-id="depiction.global_id" />
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </template>
        <hr class="divisor" />

        <div class="flex-separate">
          <slot name="infoColumn" />
          <div
            v-if="depiction && !edit"
            class="full_width panel content"
          >
            <h3>Depiction</h3>
            <ul class="no_bullets">
              <li v-if="depiction.figure_label">
                <span>Label:</span>
                <b v-html="depiction.figure_label" />
              </li>
              <li v-if="depiction.caption">
                <span>Caption:</span>
                <b v-html="depiction.caption" />
              </li>
            </ul>
          </div>

          <ImageViewerAttributions :attributions="state.attributions" />
          <ImageViewerCitations :citations="state.citations" />
        </div>
      </template>
    </VModal>
    <div>
      <div
        class="cursor-pointer"
        @click="isModalVisible = true"
      >
        <slot>
          <div :class="[`depiction-${thumbSize}-image`]">
            <img
              class="img-thumb"
              :src="thumbUrlSrc"
              :height="imageObject.alternatives[thumbSize].height"
              :width="imageObject.alternatives[thumbSize].width"
            />
          </div>
        </slot>
      </div>
      <slot name="thumbfooter" />
    </div>
  </div>
</template>
<script setup>
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import ImageViewerAttributions from './ImageViewerAttributions.vue'
import ImageViewerCitations from './ImageViewerCitations.vue'
import SvgViewer from '@/components/Svg/SvgViewer.vue'
import { Depiction, Citation, Attribution } from '@/routes/endpoints'
import { imageSVGViewBox, imageScale } from '@/helpers/images'
import { computed, reactive, ref, watch } from 'vue'
import { IMAGE } from '@/constants'

const CONVERT_IMAGE_TYPES = ['image/tiff']
const IMG_MAX_SIZES = {
  thumb: 100,
  medium: 300
}

const props = defineProps({
  depiction: {
    type: Object,
    default: undefined
  },

  edit: {
    type: Boolean,
    default: false
  },

  image: {
    type: Object,
    default: undefined
  },

  thumbSize: {
    type: String,
    default: 'thumb'
  }
})

const isModalVisible = ref(false)
const state = reactive({
  fullSizeImage: true,
  alreadyLoaded: false,
  attributions: [],
  citations: []
})

const image = computed(() =>
  state.fullSizeImage
    ? props.depiction?.image || props.image
    : props.depiction?.image.alternatives.medium ||
      props.image.alternatives.medium
)

const svgClip = computed(() => {
  return props.depiction?.svg_clip
    ? [
        {
          g: props.depiction.svg_clip,
          attributes: { fill: '#FFA500', 'fill-opacity': 0.25 }
        }
      ]
    : null
})

const imageObject = computed(() => props.depiction?.image || props.image)
const isUnsupportedType = computed(() =>
  CONVERT_IMAGE_TYPES.includes(imageObject.value.content_type)
)
const originalImageUrl = computed(() =>
  isUnsupportedType.value
    ? imageObject.value.original_png
    : imageObject.value.image_file_url
)

const urlSrc = computed(() => {
  const depiction = props.depiction
  const { width, height } = image.value

  return hasSVGBox.value
    ? imageSVGViewBox(
        imageObject.value.id,
        depiction.svg_view_box,
        width,
        height
      )
    : originalImageUrl.value
})

const hasSVGBox = computed(() => props.depiction?.svg_view_box != null)

const thumbUrlSrc = computed(() => {
  const depiction = props.depiction

  return props.hasSVGBox
    ? imageSVGViewBox(
        imageObject.value.id,
        depiction.svg_view_box,
        IMG_MAX_SIZES[props.thumbSize],
        IMG_MAX_SIZES[props.thumbSize]
      )
    : imageObject.value.alternatives[props.thumbSize].image_file_url
})

const loadAttributions = async () => {
  state.citations = (
    await Citation.where({
      citation_object_id: imageObject.value.id,
      citation_object_type: IMAGE,
      extend: ['source']
    })
  ).body
  state.attributions = (
    await Attribution.where({
      attribution_object_id: imageObject.value.id,
      attribution_object_type: IMAGE,
      extend: ['roles']
    })
  ).body
}

const updateDepiction = () => {
  const depiction = {
    caption: props.depiction.caption,
    figure_label: props.depiction.figure_label
  }

  Depiction.update(props.depiction.id, { depiction }).then(() => {
    TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
  })
}

const openFullsize = () => {
  window.open(imageObject.value.image_file_url, '_blank')
}

watch(isModalVisible, (newVal) => {
  if (newVal && !state.alreadyLoaded) {
    loadAttributions()
    state.alreadyLoaded = true
  }
})
</script>

<style lang="scss">
.depiction-thumb-image {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100px;
  height: 100px;
  border: 1px solid black;
  overflow: hidden;
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

  .depiction-modal-container {
    .modal-container {
      width: fit-content;
      max-width: 90vw;
      max-height: 90vh;
      min-width: 700px;
      max-width: 100vw;
      overflow: auto;
      box-sizing: border-box;
    }
  }

  .img-thumb {
    cursor: pointer;
  }

  .img-maxsize {
    transition: all 0.5s ease;
    max-width: 100%;
    max-height: 60vh;
  }

  .field {
    input,
    textarea {
      width: 100%;
    }
  }

  .image-container {
    display: flex;
    justify-content: center;
    img {
      border: 1px solid black;
    }
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
