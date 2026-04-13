<template>
  <div class="image-container panel content">
    <VDropzone
      class="dropzone-card"
      @vdropzone-success="success"
      ref="dropzone"
      url="/images"
      use-custom-dropzone-options
      :dropzone-options="DROPZONE_CONFIG"
    />
    <template v-if="images.length">
      <div class="flex-wrap-row separate-top">
        <ImageViewer
          v-for="image in images"
          :key="image.id"
          :image="image"
          edit
          @delete="removeImage"
        >
          <template #thumbfooter>
            <div
              class="flex-separate gap-xsmall padding-xsmall-bottom padding-xsmall-top"
            >
              <RadialAnnotator
                type="annotations"
                :global-id="image.global_id"
              />
              <RadialObject :global-id="image.global_id" />
              <RadialNavigator :global-id="image.global_id" />
              <VBtn
                circle
                color="destroy"
                @click="() => removeImage(image)"
              >
                <VIcon
                  x-small
                  name="trash"
                />
              </VBtn>
            </div>
          </template>
        </ImageViewer>
      </div>
      <div class="margin-medium-top">
        <VBtn
          medium
          color="primary"
          @click="clearImages"
        >
          Clear images
        </VBtn>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ActionNames } from '../../store/actions/actions.js'
import { GetterNames } from '../../store/getters/getters.js'
import { useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import VDropzone from '@/components/dropzone.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'

const DROPZONE_CONFIG = {
  paramName: 'image[image_file]',
  url: '/images',
  autoProcessQueue: true,
  parallelUploads: 1,
  timeout: 600000,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop images here',
  acceptedFiles: 'image/*,.heic'
}

const images = defineModel({
  type: Array,
  required: true
})

const emit = defineEmits(['created', 'onClear', 'delete'])

const dropzoneRef = useTemplateRef('dropzone')
const store = useStore()

function success(file, response) {
  const isCreated = images.value.some((item) => item.id === response.id)

  dropzoneRef.value.removeFile(file)

  if (!isCreated) {
    images.value.push(response)
    emit('created', response)
    store.dispatch(ActionNames.SetAllApplied, false)
  }
}

function removeImage(image) {
  if (window.confirm('Are you sure want to proceed?')) {
    emit('delete', image)
  }
}

function clearImages() {
  const message = store.getters[GetterNames.IsAllApplied]
    ? 'Are you sure you want to clear the images?'
    : 'You have images without applying changes, are you sure you want to clean the images?'

  if (window.confirm(message)) {
    images.value = []
    emit('onClear')
  }
}
</script>
