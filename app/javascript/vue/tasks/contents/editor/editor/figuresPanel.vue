<template>
  <div
    class="horizontal-left-content align-start gap-medium padding-medium-top"
    v-if="store.panels.figures && store.content.id"
  >
    <VDraggable
      v-model="store.depictions"
      :options="{ filter: '.dropzone-card', handle: '.card-handle' }"
      @end="
        () => {
          updatePosition()
        }
      "
      class="item item1 column-medium flex-wrap-row gap-medium"
      item-key="id"
    >
      <template #item="{ element }">
        <figure-item
          :figure="element"
          @link="emit('selected', $event)"
        />
      </template>
    </VDraggable>
    <VDropzone
      class="dropzone-card"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      ref="figure"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"
    />
    <div class="item item2 column-tiny no-margin" />
  </div>
</template>

<script setup>
import VDraggable from 'vuedraggable'
import VDropzone from '@/components/dropzone.vue'
import FigureItem from './figureItem.vue'
import useContentStore from '../store/store.js'
import { ref, useTemplateRef, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { CONTENT } from '@/constants'

const dropzone = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  headers: {
    'X-CSRF-Token': document
      .querySelector('[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop images here to add figures',
  acceptedFiles: 'image/*,.heic'
}

const emit = defineEmits(['selected'])

const store = useContentStore()
const figureRef = useTemplateRef('figure')

watch(
  () => store.content.id,
  (newVal) => {
    if (newVal) {
      Depiction.where({
        depiction_object_id: store.content.id,
        depiction_object_type: CONTENT
      }).then(({ body }) => {
        store.depictions = body.toSorted((a, b) => a.position - b.position)
      })
    } else {
      store.depictions = []
    }
  }
)

function success(file, response) {
  store.depictions.push(response)
  figureRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append('depiction[depiction_object_id]', store.content.id)
  formData.append('depiction[depiction_object_type]', CONTENT)
}

function updatePosition() {
  Depiction.sort({
    depiction_ids: store.depictions.map((depiction) => depiction.id)
  })
}
</script>
