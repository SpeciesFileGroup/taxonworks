<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    :empty="!biologicalAssociations.length"
    menu
    @menu="showModal = true"
  >
    <SlidingStack
      v-if="filteredList.length"
      scroll-offset-element="#browse-otu-header"
      :scroll-offset="100"
    >
      <template #master="{ push }">
        <div class="overflow-x-auto">
          <PanelBiologicalAssociationsTable
            :list="filteredList"
            :show-ranks="showRanks"
            @open-detail="push"
          />
        </div>
      </template>

      <template #detail="{ payload, push, pop }">
        <PanelBiologicalAssociationsDetail
          :association="payload"
          @close="pop"
          @open-detail="push"
        />
      </template>
    </SlidingStack>

    <div v-else>No biological associations available.</div>

    <VModal
      v-if="showModal"
      @close="showModal = false"
      :container-style="{ width: '900px' }"
    >
      <template #header>
        <h3>Filter</h3>
      </template>
      <template #body>
        <div class="full_width separate-bottom">
          <h4>Columns</h4>
          <ul class="no_bullets">
            <li>
              <label>
                <input
                  v-model="showRanks"
                  type="checkbox"
                />
                Show subject and object ranks (order, family, genus)
              </label>
            </li>
          </ul>
        </div>
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
import { useUserPreferences } from '@/composables'
import { copyObject } from '@/helpers'
import PanelLayout from '../PanelLayout.vue'
import VModal from '@/components/ui/Modal'
import SlidingStack from '@/components/ui/SlidingStack.vue'
import PanelBiologicalAssociationsTable from './PanelBiologicalAssociationsTable.vue'
import PanelBiologicalAssociationsDetail from './PanelBiologicalAssociationsDetail.vue'
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

const KEY_STORAGE = 'task::BrowseOtus'

const userPref = useUserPreferences()

const preferences = computed(
  () => userPref.preferences.value.layout?.[KEY_STORAGE]
)

const biologicalAssociations = ref([])
const isLoading = ref(false)
const showModal = ref(false)
const otusFilter = ref([])
const relationsFilter = ref([])
const sourcesFilter = ref([])

const showRanks = computed({
  get: () => preferences.value?.biologicalAssociations?.showRanks ?? false,

  set(value) {
    if (!preferences.value) return

    preferences.value.biologicalAssociations = {
      ...preferences.value.biologicalAssociations,
      showRanks: value
    }

    userPref.setPreference(KEY_STORAGE, copyObject(preferences.value))
  }
})

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

async function loadBiologicalAssociations(otuIds) {
  isLoading.value = true

  try {
    const { body } = await BiologicalAssociation.filter({
      otu_id: otuIds,
      extend: EXTEND
    })

    biologicalAssociations.value = await listAdapter(body)
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length) {
      const otuIds = newVal.map((o) => o.id)

      loadBiologicalAssociations(otuIds)
    }
  },
  { immediate: true }
)
</script>
