<template>
  <div class="depiction-container">
    <VDropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
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
      v-if="figuresList.length"
    >
      <ImageViewer
        v-for="item in figuresList"
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
            <ZoomImage
              :data="getImageDepictionUrl(item)"
              :depiction="item"
            />
          </div>
        </template>
      </ImageViewer>
    </div>
  </div>
</template>

<script setup>
import ActionNames from '../../store/actions/actionNames'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VDropzone from '@/components/dropzone.vue'
import ZoomImage from './zoomImage.vue'
import VPagination from '@/components/pagination.vue'

import { getPagination } from '@/helpers'
import { Depiction } from '@/routes/endpoints'
import { imageSVGViewBox } from '@/helpers/images'

import { ref, watch } from 'vue'
import { useStore } from 'vuex'

const DROPZONE_ID = Math.random().toString(36).substr(2, 5)

const props = defineProps({
  actionSave: {
    type: String,
    required: true
  },
  objectValue: {
    type: Object,
    required: true
  },
  objectType: {
    type: String,
    required: true
  },
  defaultMessage: {
    type: String,
    default: 'Drop images or click here to add figures'
  }
})

const emit = defineEmits(['create', 'delete'])

const dropzoneConfig = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: false,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: props.defaultMessage,
  acceptedFiles: 'image/*,.heic'
}

const store = useStore()
const creatingType = ref(false)
const pagination = ref({})

const dropzoneRef = ref(null)
const figuresList = ref([])

watch(
  () => props.objectValue,
  (newVal, oldVal) => {
    if (newVal.id && newVal.id != oldVal.id) {
      dropzoneRef.value.setOption('autoProcessQueue', true)
      dropzoneRef.value.processQueue()
      loadDepictions({ id: newVal.id, type: props.objectType })
    } else if (!newVal.id) {
      figuresList.value = []
      dropzoneRef.value.setOption('autoProcessQueue', false)
    }
  }
)

function success(file, response) {
  figuresList.value.push(response)
  dropzoneRef.value.removeFile(file)
  emit('create', response)
}

function sending(file, xhr, formData) {
  formData.append('depiction[depiction_object_id]', props.objectValue.id)
  formData.append('depiction[depiction_object_type]', props.objectType)
}

function addedfile() {
  if (!props.objectValue.id && !creatingType.value) {
    creatingType.value = true
    store.dispatch(ActionNames[props.actionSave], props.objectValue).then(
      (data) => {
        if (!data?.id) return
        setTimeout(() => {
          dropzoneRef.value.setOption('autoProcessQueue', true)
          dropzoneRef.value.processQueue()
          creatingType.value = false
        }, 500)
      },
      () => {
        creatingType.value = false
      }
    )
  }
}

function removeDepiction(depiction) {
  if (window.confirm('Are you sure want to proceed?')) {
    Depiction.destroy(depiction.id).then(() => {
      TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
      figuresList.value.splice(
        figuresList.value.findIndex((figure) => figure.id === depiction.id),
        1
      )
      emit('delete', depiction)
    })
  }
}

function error(event) {
  TW.workbench.alert.create(
    `There was an error uploading the image: ${event.xhr.responseText}`,
    'error'
  )
}

function getImageDepictionUrl(depiction) {
  return depiction.svg_view_box
    ? makeSVGViewbox(depiction)
    : {
        imageUrl: depiction.image.image_display_url,
        width: depiction.image.width,
        height: depiction.image.height
      }
}

function loadDepictions({ id, type, page = 1 }) {
  Depiction.where({
    depiction_object_id: id,
    depiction_object_type: type,
    page,
    per: 50
  })
    .then((response) => {
      pagination.value = getPagination(response)
      figuresList.value = response.body
    })
    .catch(() => {})
}

function makeSVGViewbox(depiction) {
  const width = Math.floor(window.innerWidth * 0.75)
  const height =
    window.innerHeight * 0.4 < 400 ? Math.floor(window.innerHeight * 0.4) : 400
  const imageUrl = imageSVGViewBox(
    depiction.image.id,
    depiction.svg_view_box,
    width,
    height
  )

  return {
    imageUrl,
    width,
    height
  }
}
</script>
<style scoped>
.depiction-container {
  width: 100%;
  max-width: 100%;
}
.depictions-list {
  max-height: 300px;
  overflow-y: auto;
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
  -webkit-transition: background 0.3s;
  transition: background 0.3s;
}

::-webkit-scrollbar-corner {
  background: 0 0;
}

::-webkit-scrollbar-thumb {
  border-radius: 0.25rem;
  background-color: rgb(156, 163, 175);
}

::-webkit-scrollbar-track {
  background-color: rgb(229, 231, 235);
}
</style>
