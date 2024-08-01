<template>
  <div class="depiction_annotator">
    <VSpinner v-if="isLoading" />
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
      <MoveTo v-model="selectedObject" />

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
          <div class="horizontal-left-content align-start gap-medium">
            <div class="flex-wrap-column gap-medium filter-tab">
              <VBtn
                color="primary"
                medium
                @click="() => loadList(parameters)"
                >Search</VBtn
              >
              <FilterImage v-model="parameters" />
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
      <VPagination
        class="margin-large-top"
        :pagination="pagination"
        @next-page="({ page }) => loadDepictions(page)"
      />
      <DepictionList
        :list="list"
        @delete="removeItem"
        @selected="(item) => (depiction = item)"
        @update:caption="updateDepiction"
        @update:label="updateDepiction"
      />
      <VPagination
        :pagination="pagination"
        @next-page="({ page }) => loadDepictions(page)"
      />
    </div>
  </div>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import FilterImage from '@/tasks/images/filter/components/filter'
import SmartSelector from '@/components/ui/SmartSelector'
import DepictionList from './DepictionList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VPagination from '@/components/pagination.vue'
import MoveTo from './MoveTo.vue'
import { getPagination } from '@/helpers'
import { useSlice } from '@/components/radials/composables'
import { Depiction, Image } from '@/routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'

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

const parameters = ref({})
const depiction = ref()
const pagination = ref({})
const isDataDepiction = ref(false)
const selectedObject = ref()
const filterList = ref([])
const figureRef = ref(null)
const isLoading = ref(false)
const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const updateObjectType = computed(() => selectedObject.value)

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
    depiction.value.depiction_object_type = selectedObject.value.type
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
  isLoading.value = true
  Image.filter(params)
    .then(({ body }) => {
      filterList.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function removeItem(item) {
  Depiction.destroy(item.id).then((_) => {
    removeFromList(item)
  })
}

function loadDepictions(page = 1) {
  Depiction.where({
    depiction_object_id: props.objectId,
    depiction_object_type: props.objectType,
    per: 50,
    page
  }).then((response) => {
    list.value = response.body
    pagination.value = getPagination(response)
  })
}

onBeforeMount(() => loadDepictions())
</script>

<style scoped>
.filter-tab {
  width: 400px;
}
</style>
