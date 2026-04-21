<template>
  <div>
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      ref="dropzone"
      id="depiction"
      url="/depictions"
      use-custom-dropzone-options
      :dropzone-options="dropzoneConfig"
    />
    <div
      class="flex-wrap-row"
      v-if="depictionStore.depictions.length"
    >
      <ImageViewer
        v-for="item in depictionStore.depictions"
        :key="item.id"
        :depiction="item"
        edit
        @delete="removeDepiction"
      >
        <template #thumbfooter>
          <div
            class="horizontal-left-content padding-xsmall-bottom padding-xsmall-top gap-small"
          >
            <button
              @click="removeDepiction(item)"
              class="button circle-button btn-delete"
            />
          </div>
        </template>
      </ImageViewer>
    </div>
  </div>
</template>

<script setup>
import { computed, useTemplateRef, watch, nextTick } from 'vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import Dropzone from '@/components/dropzone.vue'
import useStore from '../../store/store.js'
import useDepictionStore from '../../store/depictions.js'

const dropzoneConfig = computed(() => ({
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: !!store.typeMaterial.id,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop images here to add figures',
  acceptedFiles: 'image/*,.heic'
}))

const dropzoneRef = useTemplateRef('dropzone')

const store = useStore()
const depictionStore = useDepictionStore()

function success(file, response) {
  depictionStore.depictions.push(response)
  dropzoneRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append(
    'depiction[depiction_object_id]',
    store.typeMaterial.collectionObject.id
  )
  formData.append('depiction[depiction_object_type]', 'CollectionObject')
}

function removeDepiction(depiction) {
  if (window.confirm('Are you sure want to proceed?')) {
    depictionStore.destroy(depiction)
  }
}

const unsubscribe = store.$onAction(({ name }) => {
  const actionNames = ['setCollectionObject', 'setTypeMaterial']

  if (actionNames.includes(name)) {
    dropzoneRef.value?.removeAllFiles()
  }
})

watch(
  () => store.typeMaterial.id,
  (newVal) => {
    if (newVal) {
      nextTick(() => {
        dropzoneRef.value?.processQueue()
      })
    }
  }
)
</script>
