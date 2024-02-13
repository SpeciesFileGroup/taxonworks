<template>
  <div class="depiction_annotator">
    <div
      class="field"
      v-if="depiction"
    >
      <div class="separate-bottom">
        <img
          :src="depiction.image.alternatives.medium.image_file_url"
          :style="{
            width: `${depiction.image.alternatives.medium.width}px`,
            height: `${depiction.image.alternatives.medium.height}px`
          }"
        />
      </div>
      <div class="field">
        <input
          class="normal-input"
          type="text"
          v-model="depiction.figure_label"
          placeholder="Label"
        />
      </div>
      <div class="field">
        <textarea
          class="normal-input full_width margin-small-top margin-small-bottom padding-medium"
          rows="5"
          type="text"
          v-model="depiction.caption"
          placeholder="Caption"
        />
      </div>
      <label>
        <input
          type="checkbox"
          v-model="depiction.is_metadata_depiction"
        />
        Is data depiction
      </label>
      <div class="separate-top separate-bottom">
        <h4>Move to</h4>
        <ul class="no_bullets">
          <li
            v-for="type in OBJECT_TYPES"
            :key="type.value"
          >
            <label>
              <input
                type="radio"
                name="depiction-type"
                v-model="selectedType"
                :value="type"
              />
              {{ type.label }}
            </label>
          </li>
        </ul>
        <div
          v-if="selectedType && !selectedObject"
          class="separate-top"
        >
          <autocomplete
            v-if="selectedType.value != 'Otu'"
            :disabled="!selectedType"
            :url="selectedType.url"
            label="label_html"
            :placeholder="`Select a ${selectedType.label.toLowerCase()}`"
            :clear-after="true"
            @get-item="(item) => (selectedObject = item)"
            param="term"
          />
          <otu-picker
            v-else
            :clear-after="true"
            @get-item="(otu) => (selectedObject = otu)"
          />
        </div>
        <div
          v-if="selectedObject"
          class="horizontal-left-content"
        >
          <span v-html="selectedObject.label_html" />
          <span
            class="circle-button button-default btn-undo"
            @click="selectedObject = undefined"
          />
        </div>
      </div>

      <div>
        <button
          type="button"
          class="normal-input button button-submit margin-small-right"
          @click="updateFigure()"
        >
          Update
        </button>
        <button
          type="button"
          class="normal-input button button-default"
          @click="depiction = undefined"
        >
          Back
        </button>
      </div>
    </div>
    <div v-else>
      <SmartSelector
        model="images"
        :autocomplete="false"
        :search="false"
        :target="objectType"
        :add-tabs="['new', 'filter']"
        pin-section="Images"
        @selected="createDepiction"
      >
        <template #new>
          <dropzone
            class="dropzone-card separate-bottom"
            @vdropzone-sending="sending"
            @vdropzone-success="success"
            ref="figureRef"
            url="/depictions"
            :use-custom-dropzone-options="true"
            :dropzone-options="DROPZONE_CONFIG"
          />
        </template>
        <template #filter>
          <div class="horizontal-left-content align-start">
            <div class="flex-wrap-column gap-medium">
              <FilterImage @parameters="loadList" />
            </div>
            <div class="margin-small-left flex-wrap-row">
              <div
                v-for="image in filterList"
                :key="image.id"
                class="thumbnail-container margin-small cursor-pointer"
                @click="createDepiction(image)"
              >
                <img
                  :width="image.alternatives.thumb.width"
                  :height="image.alternatives.thumb.height"
                  :src="image.alternatives.thumb.image_file_url"
                />
              </div>
            </div>
          </div>
        </template>
      </SmartSelector>
      <label>
        <input
          type="checkbox"
          v-model="isDataDepiction"
        />
        Is data depiction
      </label>
      <DepictionList
        class="margin-large-top"
        :list="list"
        @delete="removeItem"
        @selected="(item) => (depiction = item)"
        @update:caption="updateDepiction"
        @update:label="updateDepiction"
      />
    </div>
  </div>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import Autocomplete from '@/components/ui/Autocomplete'
import OtuPicker from '@/components/otu/otu_picker/otu_picker'
import FilterImage from '@/tasks/images/filter/components/filter'
import SmartSelector from '@/components/ui/SmartSelector'
import DepictionList from './DepictionList.vue'
import { useSlice } from '@/components/radials/composables'
import { Depiction, Image } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const DROPZONE_CONFIG = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop images here to add figures',
  acceptedFiles: 'image/*,.heic'
}

const OBJECT_TYPES = [
  {
    value: 'Otu',
    label: 'Otu',
    url: '/otus/autocomplete'
  },
  {
    value: 'CollectingEvent',
    label: 'Collecting event',
    url: '/collecting_events/autocomplete'
  },
  {
    value: 'CollectionObject',
    label: 'Collection object',
    url: '/collection_objects/autocomplete'
  },
  {
    value: 'TaxonName',
    label: 'Taxon name',
    url: '/taxon_names/autocomplete'
  },
  {
    value: 'Person',
    label: 'Person',
    url: '/people/autocomplete'
  }
]

const props = defineProps({
  globalId: {
    type: String,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  objectId: {
    type: Number,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const depiction = ref()
const isDataDepiction = ref(false)
const selectedType = ref()
const selectedObject = ref()
const filterList = ref([])
const figureRef = ref(null)
const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const updateObjectType = computed(
  () => selectedObject.value && selectedType.value
)

function success(file, response) {
  addToList(response)
  figureRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append(
    'depiction[annotated_global_entity]',
    decodeURIComponent(props.globalId)
  )
  formData.append('depiction[is_metadata_depiction]', isDataDepiction.value)
}

function updateFigure() {
  if (updateObjectType.value) {
    depiction.value.depiction_object_type = selectedType.value.value
    depiction.value.depiction_object_id = selectedObject.value.id
  }

  Depiction.update(depiction.value.id, { depiction: depiction.value }).then(
    ({ body }) => {
      if (updateObjectType.value) {
        removeFromList(body)
      } else {
        addToList(body)
      }
      depiction.value = undefined

      TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
    }
  )
}

function updateDepiction(depiction) {
  Depiction.update(depiction.id, { depiction }).then(({ body }) => {
    addToList(body)

    TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
  })
}

function createDepiction(image) {
  const depiction = {
    image_id: image.id,
    annotated_global_entity: props.globalId,
    is_metadata_depiction: isDataDepiction.value
  }

  Depiction.create({ depiction }).then(({ body }) => {
    addToList(body)
    TW.workbench.alert.create('Depiction was successfully created.', 'notice')
  })
}

function loadList(params) {
  Image.filter(params).then(({ body }) => {
    filterList.value = body
  })
}

function removeItem(item) {
  Depiction.destroy(item.id).then((_) => {
    removeFromList(item)
  })
}

Depiction.where({
  depiction_object_id: props.objectId,
  depiction_object_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>
