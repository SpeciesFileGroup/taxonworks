<template>
  <div title="Drop image here">
    <spinner-component
      :legend="('Uploading...')"
      v-if="isLoading"
    />
    <dropzone-component
      v-show="show"
      class="dropzone-card"
      ref="dropzoneElement"
      url="/observations"
      use-custom-dropzone-options
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      @click="openInputFile"
      :dropzone-options="
        existObservations
          ? dropzoneDepiction
          : dropzoneObservation
      "
    >
      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        group="cells"
        item-key="id"
        :list="depictions"
        @click.stop="openInputFile"
        @add="movedDepiction"
        @choose="setObservationDragged"
      >
        <template #item="{ element }">
          <div
            @click.stop
            title=""
            class="drag-container"
          >
            <image-viewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div class="horizontal-left-content margin-small-top">
                  <radial-annotator
                    type="annotations"
                    :global-id="element.image.global_id"
                  />
                  <button-citation
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
            </image-viewer>
          </div>
        </template>
      </draggable-component>
    </dropzone-component>
    <v-icon
      v-if="!show && existObservations"
      name="image"
    />
  </div>
</template>

<script setup>

import DropzoneComponent from 'components/dropzone'
import DraggableComponent from 'vuedraggable'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import SpinnerComponent from 'components/spinner'
import VIcon from 'components/ui/VIcon/index.vue'
import ButtonCitation from './ButtonCitation.vue'
import { useStore } from 'vuex'
import { ref, computed } from 'vue'
import { Observation, Depiction } from 'routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { OBSERVATION_MEDIA } from 'constants/index'

const CSRF_TOKEN = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

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

const emit = defineEmits([
  'removeDepiction',
  'addDepiction'
])

const store = useStore()
const dropzoneElement = ref(null)

const observationMoved = computed({
  get: () => store.getters[GetterNames.GetObservationMoved],
  set: value => store.commit(MutationNames.SetObservationMoved, value)
})

const depictionMoved = computed({
  get: () => store.getters[GetterNames.GetDepictionMoved],
  set: value => store.commit(MutationNames.SetDepictionMoved, value)
})

const existObservations = computed(() => props.depictions.length > 0)
const rowObjectId = computed(() => props.rowObject.observation_object_id || props.rowObject.id)
const rowObjectType = computed(() => props.rowObject.observation_object_type || props.rowObject.base_class)
const observationId = computed(() => props.depictions.length && props.depictions[0].depiction_object_id)

const isLoading = ref(false)

function movedDepiction (_) {
  if (props.depictions.length === 1 && (depictionMoved.value.depiction_object_id === observationId.value || depictionMoved.value.depiction_object_type !== 'Observation')) {
    const observation = {
      descriptor_id: props.descriptorId,
      type: OBSERVATION_MEDIA,
      observation_object_type: rowObjectType.value,
      observation_object_id: rowObjectId.value
    }

    store.commit(MutationNames.SetIsSaving, true)

    Observation.create({ observation, extend: ['depictions'] })
      .then(({ body }) => {
        store.dispatch(ActionNames.MoveDepiction, {
          columnIndex: props.columnIndex,
          rowIndex: props.rowIndex,
          observationId: body.id
        })
      })
      .catch(() => store.commit(MutationNames.SetIsSaving, false))
  } else {
    store.dispatch(ActionNames.MoveDepiction, {
      columnIndex: props.columnIndex,
      rowIndex: props.rowIndex,
      observationId: observationId.value
    })
  }
}

function openInputFile () {
  dropzoneElement.value.$el.click()
}

function setObservationDragged (event) {
  depictionMoved.value = props.depictions[event.oldIndex]
  observationMoved.value = observationId.value
}

function removeDepiction (depiction) {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    store.commit(MutationNames.SetIsSaving, true)

    Depiction.destroy(depiction.id).then(() => {
      const index = props.depictions.findIndex(item => item.id === depiction.id)

      emit('removeDepiction', index)
      store.commit(MutationNames.SetIsSaving, false)
    })
  }
}

function success (file, response) {
  if (!existObservations.value) {
    dropzoneElement.value.setOption('url', dropzoneDepiction.url)
    dropzoneElement.value.setOption('paramName', dropzoneDepiction.paramName)
  }

  addDepiction(response.base_class === 'Depiction' ? response : response.depictions[0])

  dropzoneElement.value.removeFile(file)
  isLoading.value = false
}

function sending (file, xhr, formData) {
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

function addDepiction (depiction) {
  store.commit(MutationNames.AddDepiction, {
    columnIndex: props.columnIndex,
    rowIndex: props.rowIndex,
    depiction
  })
}

</script>

<style scoped>
  .dropzone-card {
    align-items: stretch;
    flex: 1
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
