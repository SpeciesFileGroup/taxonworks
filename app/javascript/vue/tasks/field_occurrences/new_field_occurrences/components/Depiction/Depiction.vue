<template>
  <BlockLayout :warning="!isFilled">
    <template #header>
      <h3>Depictions</h3>
    </template>

    <template #body>
      <div class="depiction-container">
        <VDropzone
          class="dropzone-card separate-bottom"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
          @vdropzone-error="error"
          ref="dropzoneRef"
          :id="`depiction-${DROPZONE_ID}`"
          url="/depictions"
          use-custom-dropzone-options
          :dropzone-options="dropzoneConfig"
        />

        <VPagination
          :pagination="pagination"
          @next-page="
            ({ page }) =>
              loadDepictions({ id: objectValue.id, type: objectType, page })
          "
        />
        <div
          class="flex-wrap-row depictions-list"
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
  </BlockLayout>
</template>

<script setup>
import { Depiction } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { FIELD_OCCURRENCE } from '@/constants'
import { randomUUID } from '@/helpers'
import useFieldOccurrenceStore from '../../store/fieldOccurrence'
import useDepictionStore from '../../store/depictions'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VDropzone from '@/components/dropzone.vue'
import VPagination from '@/components/pagination.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const DROPZONE_ID = Math.random().toString(36).substr(2, 5)

const props = defineProps({
  defaultMessage: {
    type: String,
    default: 'Drop images or click here to add figures'
  }
})

const emit = defineEmits(['create', 'delete'])

const fieldOcurrenceStore = useFieldOccurrenceStore()
const depictionStore = useDepictionStore()
const pagination = ref({})
const dropzoneRef = ref(null)

const fieldOccurrenceId = computed(() => fieldOcurrenceStore.fieldOccurrence.id)
const dropzoneConfig = computed(() => ({
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: !!fieldOccurrenceId.value,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: props.defaultMessage,
  acceptedFiles: 'image/*,.heic'
}))

function success(file, response) {
  dropzoneRef.value.removeFile(file)
  depictionStore.depictions.push({
    ...response,
    uuid: randomUUID(),
    isUnsaved: false
  })
}

function sending(file, xhr, formData) {
  formData.append('depiction[depiction_object_id]', fieldOccurrenceId.value)
  formData.append('depiction[depiction_object_type]', FIELD_OCCURRENCE)
}

fieldOcurrenceStore.$onAction(({ name, after }) => {
  if (name === 'save') {
    after(() => {
      if (fieldOcurrenceStore.fieldOccurrence.id) {
        dropzoneRef.value.processQueue()
      }
    })
  }
})

function removeDepiction(depiction) {
  if (window.confirm('Are you sure want to proceed?')) {
    depictionStore.remove(depiction)
  }
}

function error(event) {
  TW.workbench.alert.create(
    `There was an error uploading the image: ${event.xhr.responseText}`,
    'error'
  )
}
</script>
