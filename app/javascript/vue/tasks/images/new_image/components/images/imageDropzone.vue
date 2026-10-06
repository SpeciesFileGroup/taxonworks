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
        <div
          v-for="image in images"
          :key="image.id"
          class="image-applied-container"
        >
          <VBadge
            v-if="appliedBadges[image.id]"
            class="image-applied-badge"
            :color="appliedBadges[image.id].color"
            v-tooltip="appliedBadges[image.id].title"
          >
            <VIcon
              small
              :name="appliedBadges[image.id].icon"
            />
          </VBadge>
          <ImageViewer
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
import { GetterNames } from '../../store/getters/getters.js'
import { computed, useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import { vTooltip } from '@/directives/tooltip.js'
import VDropzone from '@/components/dropzone.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
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
const appliedBadges = computed(() =>
  Object.fromEntries(
    images.value.map((image) => [image.id, makeAppliedBadge(image.id)])
  )
)

function makeAppliedBadge(imageId) {
  const { applied, pending } =
    store.getters[GetterNames.GetImageAppliedStatus](imageId)

  if (pending.length) {
    return {
      color: 'yellow',
      icon: 'attention',
      title: [
        `Pending: ${pending.join(', ')}`,
        applied.length ? `Applied: ${applied.join(', ')}` : undefined
      ]
        .filter(Boolean)
        .join('. ')
    }
  }

  return applied.length
    ? {
        color: 'green',
        icon: 'check',
        title: `Applied: ${applied.join(', ')}`
      }
    : undefined
}

function success(file, response) {
  const isCreated = images.value.some((item) => item.id === response.id)

  dropzoneRef.value.removeFile(file)

  if (!isCreated) {
    images.value.push(response)
    emit('created', response)
  }
}

function removeImage(image) {
  if (window.confirm('Are you sure you want to proceed?')) {
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

<style scoped>
.image-applied-container {
  position: relative;
}

.image-applied-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 1;
  display: flex;
  padding: 2px 4px;
}
</style>
