<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    menu
    @menu="showModal = true"
  >
    <div class="overflow-x-auto">
      <PanelBiologicalAssociationsTable :list="filteredList" />
    </div>
    <VModal
      v-if="showModal"
      @close="showModal = false"
      :container-style="{ width: '900px' }"
    >
      <template #header>
        <h3>Filter</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <div class="full_width margin-small-right">
            <h4>Relations</h4>
            <PanelBiologicalAssociationsFilterList
              class="overflow-y-scroll"
              :list="relationList"
              v-model="relationsFilter"
            />
          </div>
          <div class="full_width margin-left-margin">
            <h4>Otus</h4>
            <PanelBiologicalAssociationsFilterList
              class="overflow-y-scroll"
              :list="otusList"
              v-model="otusFilter"
            />
          </div>
        </div>
        <div class="full_width margin-left-margin">
          <h4>Sources</h4>
          <PanelBiologicalAssociationsFilterList
            class="overflow-y-scroll"
            :list="sourcesList"
            v-model="sourcesFilter"
          />
        </div>
      </template>
    </VModal>
  </PanelLayout>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import { getUnique, sortArray } from '@/helpers/arrays.js'
import PanelLayout from '../PanelLayout.vue'
import VModal from '@/components/ui/Modal'
import PanelBiologicalAssociationsTable from './PanelBiologicalAssociationsTable.vue'
import PanelBiologicalAssociationsFilterList from './PanelBiologicalAssociationsFilterList.vue'
import { listAdapter, EXTEND } from './utils/listAdapter.js'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Biological associations'
  }
})

const biologicalAssociations = ref([])
const isLoading = ref(false)
const showModal = ref(false)
const otusFilter = ref([])
const relationsFilter = ref([])
const sourcesFilter = ref([])

const filteredList = computed(() =>
  biologicalAssociations.value.filter(
    (biological) =>
      (!otusFilter.value.length ||
        otusFilter.value.includes(biological.subjectId) ||
        otusFilter.value.includes(biological.objectId)) &&
      (!relationsFilter.value.length ||
        relationsFilter.value.includes(biological.biologicalRelationshipId)) &&
      checkExist(sourcesFilter.value, biological.citations, 'source_id')
  )
)

const relationList = computed(() =>
  getUnique(
    biologicalAssociations.value.map((item) => ({
      id: item.biologicalRelationshipId,
      label: item.biologicalRelationship
    })),
    'id'
  )
)

const otusList = computed(() =>
  sortArray(
    getUnique(
      biologicalAssociations.value.flatMap((item) => [
        { label: item.subjectLabel, id: item.subjectId },
        {
          label: item.objectTag,
          objectLabel: item.objectLabel,
          id: item.objectId
        }
      ]),
      'id'
    ),
    'objectLabel'
  )
)

const sourcesList = computed(() =>
  sortArray(
    getUnique(
      biologicalAssociations.value.flatMap((biological) =>
        biological.citations.map((citation) => ({
          label: citation.source.object_tag,
          id: citation.source_id
        }))
      ),
      'id'
    ),
    'label'
  )
)

function checkExist(filterList, item, property) {
  if (Array.isArray(filterList)) {
    return filterList.length
      ? Array.isArray(item)
        ? item.find((obj) => filterList.includes(obj[property]))
        : filterList.includes(item[property])
      : true
  } else {
    return Array.isArray(item)
      ? item.find((obj) => filterList === obj[property])
      : filterList === item[property]
  }
}

async function loadBiologicalAssociations(otu) {
  isLoading.value = true

  try {
    const { body } = await BiologicalAssociation.all({
      any_global_id: [otu.global_id],
      extend: EXTEND
    })

    biologicalAssociations.value = await listAdapter(body)
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otu,
  (newVal) => {
    if (newVal?.id) {
      loadBiologicalAssociations(newVal)
    }
  },
  { immediate: true }
)
</script>
