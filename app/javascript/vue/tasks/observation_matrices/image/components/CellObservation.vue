<template>
  <div title="Drop image here">
    <VSpinner
      :legend="'Uploading...'"
      v-if="isLoading"
    />
    <VDropzone
      v-show="show"
      class="dropzone-card"
      ref="dropzoneElement"
      url="/observations"
      use-custom-dropzone-options
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      @click="openInputFile"
      :dropzone-options="
        existObservations ? dropzoneDepiction : dropzoneObservation
      "
    >
      <VDraggable
        class="flex-wrap-row matrix-image-draggable"
        item-key="id"
        :group="{ name: 'cells', pull: isClone ? 'clone' : true }"
        :list="depictions"
        @click.stop="openInputFile"
        @add="movedDepiction"
        @choose="setObservationDragged"
      >
        <template #item="{ element }">
          <div
            title=""
            class="drag-container"
            @click.stop
          >
            <ImageViewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div
                  class="horizontal-left-content padding-xsmall-bottom padding-xsmall-top gap-small"
                >
                  <RadialAnnotator
                    type="annotations"
                    :global-id="element.image.global_id"
                  />
                  <ButtonCitation
                    :global-id="element.image.global_id"
                    :citations="element.image.citations"
                  />
                  <button
                    class="button circle-button btn-delete"
                    type="button"
                    @click="removeDepiction(element)"
                  />
                </div>
              </template>
            </ImageViewer>
          </div>
        </template>
      </VDraggable>
    </VDropzone>
    <VIcon
      v-if="!show && existObservations"
      name="image"
    />
  </div>
</template>

<script setup>
import VDropzone from '@/components/dropzone'
import VDraggable from 'vuedraggable'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VSpinner from '@/components/ui/VSpinner'
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonCitation from './ButtonCitation.vue'
import { useStore } from 'vuex'
import { ref, computed } from 'vue'
import { Observation, Depiction } from '@/routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { OBSERVATION_MEDIA } from '@/constants/index'

const CSRF_TOKEN = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute('content')

const dropzoneObservation = {
  paramName: 'observation[images_attributes][][image_file]',
  url: '/observations',
  autoProcessQueue: true,
  parallelUploads: 1,
  headers: {
    'X-CSRF-Token': CSRF_TOKEN
  },
  acceptedFiles: 'image/*,.heic'
}
const dropzoneDepiction = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: true,
  headers: {
    'X-CSRF-Token': CSRF_TOKEN
  },
  acceptedFiles: 'image/*,.heic'
}

const props = defineProps({
  columnIndex: {
    type: Number,
    required: true
  },

  depictions: {
    type: Array,
    required: true
  },

  rowObject: {
    type: Object,
    required: true
  },

  rowIndex: {
    type: Number,
    required: true
  },

  descriptorId: {
    type: Number,
    required: true
  },

  show: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['removeDepiction', 'addDepiction'])

const store = useStore()
const dropzoneElement = ref(null)

const isClone = computed(() => store.getters[GetterNames.IsClone])
const observationMoved = computed({
  get: () => store.getters[GetterNames.GetObservationMoved],
  set: (value) => store.commit(MutationNames.SetObservationMoved, value)
})

const depictionMoved = computed({
  get: () => store.getters[GetterNames.GetDepictionMoved],
  set: (value) => store.commit(MutationNames.SetDepictionMoved, value)
})

const existObservations = computed(() => props.depictions.length > 0)
const rowObjectId = computed(
  () => props.rowObject.observation_object_id || props.rowObject.id
)
const rowObjectType = computed(
  () => props.rowObject.observation_object_type || props.rowObject.base_class
)
const observationId = computed(() => {
  const depictions = props.depictions

  return depictionMoved.value
    ? depictions.find(
        (d) =>
          d.depiction_object_id !== depictionMoved.value.depiction_object_id
      )?.depiction_object_id
    : depictions[0].depiction_object_id
})

const isLoading = ref(false)

function movedDepiction({ newIndex }) {
  if (props.depictions.length === 1) {
    const observation = {
      descriptor_id: props.descriptorId,
      type: OBSERVATION_MEDIA,
      observation_object_type: rowObjectType.value,
      observation_object_id: rowObjectId.value
    }

    store.commit(MutationNames.SetIsSaving, true)

    Observation.create({ observation })
      .then(({ body }) => {
        addDepiction({ observationId: body.id, newIndex })
      })
      .catch(() => store.commit(MutationNames.SetIsSaving, false))
  } else {
    addDepiction({ observationId: observationId.value, newIndex })
  }
}

function addDepiction({ observationId, newIndex }) {
  const args = {
    columnIndex: props.columnIndex,
    rowIndex: props.rowIndex,
    imageId: depictionMoved.value.image_id
  }

  if (isClone.value) {
    store.dispatch(ActionNames.CreateDepiction, {
      ...args,
      observationId
    })
  } else {
    store.dispatch(ActionNames.MoveDepiction, {
      ...args,
      observationId
    })
  }
  emit('removeDepiction', newIndex)
}

function openInputFile() {
  dropzoneElement.value.$el.click()
}

function setObservationDragged(event) {
  depictionMoved.value = props.depictions[event.oldIndex]
  observationMoved.value = observationId.value
}

function removeDepiction(depiction) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.commit(MutationNames.SetIsSaving, true)

    Depiction.destroy(depiction.id).then(() => {
      const index = props.depictions.findIndex(
        (item) => item.id === depiction.id
      )

      emit('removeDepiction', index)
      store.commit(MutationNames.SetIsSaving, false)
    })
  }
}

function success(file, response) {
  if (!existObservations.value) {
    dropzoneElement.value.setOption('url', dropzoneDepiction.url)
    dropzoneElement.value.setOption('paramName', dropzoneDepiction.paramName)
  }

  store.commit(MutationNames.AddDepiction, {
    columnIndex: props.columnIndex,
    rowIndex: props.rowIndex,
    depiction:
      response.base_class === 'Depiction' ? response : response.depictions[0]
  })

  dropzoneElement.value.removeFile(file)
  isLoading.value = false
}

function sending(file, xhr, formData) {
  if (existObservations.value) {
    formData.append('depiction[depiction_object_id]', observationId.value)
    formData.append('depiction[depiction_object_type]', 'Observation')
  } else {
    formData.append('observation[descriptor_id]', props.descriptorId)
    formData.append('observation[type]', OBSERVATION_MEDIA)
    formData.append('observation[observation_object_id]', rowObjectId.value)
    formData.append('observation[observation_object_type]', rowObjectType.value)
    formData.append('extend[]', 'depictions')
  }

  isLoading.value = true
}
</script>

<style scoped>
.dropzone-card {
  align-items: stretch;
  flex: 1;
}

:deep(.dz-message) {
  margin: 1em 0 !important;
  font-size: 16px !important;
  display: none !important;
}

.matrix-image-draggable {
  box-sizing: content-box;
  align-items: stretch;
  flex: 1;
  height: 100%;
  cursor: pointer;
}

.vue-dropzone {
  padding: 0px !important;
  min-width: 100px;
  cursor: pointer !important;
  align-items: stretch;
  flex: 1;
}

.dropzone {
  height: 100%;
}

.image-draggable {
  cursor: pointer;
}

:deep(.dz-preview) {
  display: none !important;
}
</style>
