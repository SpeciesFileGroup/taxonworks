<template>
  <div class="depiction-thumb-container">
    <modal-component
      v-if="showModal"
      class="depiction-modal-container"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Image</h3>
      </template>
      <template #body>
        <div class="flex-wrap-column middle">
          <img
            class="img-maxsize margin-medium-bottom"
            :src="urlSrc()"
          />
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
                <RadialAnnotator
                  type="annotations"
                  :global-id="image.global_id"
                  @close="loadData"
                />
              </li>
              <li>
                <RadialObject :global-id="image.global_id" />
              </li>
              <li>
                <RadialNavigation :global-id="image.global_id" />
              </li>
              <li>
                <DepictionList :image-id="[image.id]" />
              </li>
            </ul>
          </div>
        </div>
      </template>
    </modal-component>
    <div
      class="depiction-thumb-container depiction-thumb-image horizontal-center-content middle position-relative"
    >
      <img
        class="img-thumb"
        :src="image.alternatives.thumb.image_file_url"
        @click="setModalView(true)"
      />
      <div
        class="position-absolute"
        :style="{
          right: '4px',
          bottom: '4px'
        }"
      >
        <pin-component
          :object-id="image.id"
          type="Image"
        />
      </div>
      <input
        v-if="imageIds"
        class="position-absolute"
        type="checkbox"
        v-model="imageIds"
        :value="image.id"
        :style="{
          left: '4px',
          bottom: '4px'
        }"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { imageScale } from '@/helpers/images'
import ModalComponent from '@/components/ui/Modal'
import PinComponent from '@/components/ui/Button/ButtonPin.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import DepictionList from './DepictionList.vue'

const CONVERT_IMAGE_TYPES = ['image/tiff']
const props = defineProps({
  image: {
    type: Object,
    required: true
  },

  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const showModal = ref(false)

const imageIds = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const setModalView = (value) => {
  showModal.value = value
}

const urlSrc = () => {
  const { width, height } = props.image

  return CONVERT_IMAGE_TYPES.includes(props.image.content_type)
    ? imageScale(props.image.id, `0 0 ${width} ${height}`, width, height)
    : props.image.image_file_url
}

const openFullsize = () => {
  window.open(urlSrc(), '_blank')
}
</script>
