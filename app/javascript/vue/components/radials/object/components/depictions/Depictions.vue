<template>
  <div class="depiction_annotator">
    <div class="flex-wrap-column gap-medium">
      <input
        class="normal-input"
        type="text"
        v-model="depiction.figureLabel"
        placeholder="Label"
      />
      <textarea
        class="normal-input full_width"
        rows="5"
        type="text"
        v-model="depiction.caption"
        placeholder="Caption"
      />
      <label>
        <input
          type="checkbox"
          v-model="depiction.isMetadataDepiction"
        />
        Is data depiction
      </label>

      <h4>Add to</h4>
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

      <SmartSelector
        v-if="selectedType && !selectedObject"
        :model="selectedType.model"
        :klass="objectType"
        :label="objectLabelProperty"
        :target="DEPICTION"
        @selected="setSelectedObject"
      />
      <SmartSelectorItem
        v-if="selectedObject"
        :item="selectedObject"
        :label="objectLabelProperty"
        @unset="
          () => {
            setSelectedObject()
          }
        "
      />

      <div class="horizontal-left-content gap-small">
        <VBtn
          color="create"
          medium
          :disabled="!depiction.objectId || !depiction.objectType"
          @click="
            () => {
              saveDepiction(makePayload(depiction))
            }
          "
        >
          {{ depiction.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          color="primary"
          medium
          @click="
            () => {
              depiction = makeDepiction()
            }
          "
        >
          New
        </VBtn>
      </div>

      <DepictionList
        class="margin-medium-top"
        :list="list"
        @delete="removeDepiction"
        @update:caption="saveDepiction"
        @update:label="saveDepiction"
        @selected="(item) => (depiction = makeDepiction(item))"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { DEPICTION } from '@/constants'
import { removeFromArray, addToArray } from '@/helpers'
import DepictionList from '@/components/radials/annotator/components/depictions/DepictionList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const OBJECT_TYPES = [
  {
    value: 'Otu',
    model: 'otus',
    label: 'Otu'
  },
  {
    value: 'CollectingEvent',
    model: 'collecting_events',
    label: 'Collecting event'
  },
  {
    value: 'CollectionObject',
    model: 'collection_objects',
    label: 'Collection object'
  },
  {
    value: 'TaxonName',
    model: 'taxon_names',
    label: 'Taxon name'
  },
  {
    value: 'Person',
    model: 'people',
    label: 'Person'
  }
]

const props = defineProps({
  metadata: {
    type: Object,
    required: true
  },

  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['updateCount'])

const selectedType = ref(null)
const selectedObject = ref(undefined)
const depiction = ref(makeDepiction())
const list = ref([])

const objectLabelProperty = computed(() =>
  selectedType?.value === 'Person' ? 'cached' : 'object_tag'
)

function makeDepiction(item = {}) {
  return {
    id: item.id,
    figureLabel: item.figure_label,
    caption: item.caption,
    isMetadataDepiction: item.is_metadata_depiction,
    objectId: item.depiction_object_id,
    objectType: item.depiction_object_type
  }
}

function makePayload(depiction) {
  return {
    id: depiction.id,
    image_id: props.objectId,
    figure_label: depiction.figureLabel,
    caption: depiction.caption,
    is_metadata_depiction: depiction.isMetadataDepiction,
    depiction_object_type: selectedType.value?.value || depiction.objectType,
    depiction_object_id: selectedObject.value?.id || depiction.objectId
  }
}

function saveDepiction(depiction) {
  const response = depiction.id
    ? Depiction.update(depiction.id, { depiction })
    : Depiction.create({ depiction })

  response.then(({ body }) => {
    addToArray(list.value, body)
    resetForm()
    emit('updateCount', list.value.length)
    TW.workbench.alert.create('Depiction was successfully saved.', 'notice')
  })
}

function setSelectedObject(item) {
  selectedObject.value = item
  depiction.value.objectId = item?.id
  depiction.value.objectType = selectedType.value?.value
}

function resetForm() {
  depiction.value = makeDepiction()
  selectedObject.value = undefined
  selectedType.value = undefined
}

function removeDepiction(item) {
  Depiction.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('updateCount', list.value.length)
    TW.workbench.alert.create('Depiction was successfully removed.', 'notice')
  })
}

onBeforeMount(() => {
  Depiction.where({
    image_id: [props.objectId]
  }).then(({ body }) => {
    list.value = body
  })
})
</script>
