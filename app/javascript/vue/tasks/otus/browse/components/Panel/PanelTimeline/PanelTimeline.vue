<template>
  <PanelLayout
    :title="title"
    :spinner="isLoading || isBiologyLoading"
    :empty="!timeline?.items?.length"
    menu
    @menu="() => (isModalVisible = true)"
  >
    <template v-if="!isLoading && !isBiologyLoading">
      <PanelTimelineTabs
        v-model="tab"
        :tabs="TIMELINE_TABS"
      />

      <PanelTimelineBiology
        v-if="isBiologyTab"
        :items="scopedBiologyItems"
      />

      <template v-else-if="matchingItems.length">
        <div
          v-if="timeline"
          :class="hideClasses"
        >
          <TimelineCitations
            v-model:expanded="isCitationsExpanded"
            :citations="visibleCitations"
            :total-count="filteredItems.length"
            :preview-size="CITATIONS_PREVIEW_SIZE"
            :is-collapsible="isCollapsible"
          />
          <PanelTimelineReferences
            v-if="Object.keys(referenceSources).length"
            v-model="selectedReferenceIds"
            :sources="referenceSources"
            :topics-list="referenceTopics"
            :filtered-items="matchingItems"
            :show-topics="showReferencesTopic"
          />
        </div>
      </template>

      <div v-else>No citations available.</div>
    </template>

    <PanelTimelineSettings
      v-if="isModalVisible && timeline"
      v-model:topics-selected="selectedTopics"
      v-model:show-references-topic="showReferencesTopic"
      v-model:always-show-all-citations="alwaysShowAllCitations"
      :preferences="preferences"
      :nomenclature="timeline"
      @close="() => (isModalVisible = false)"
    />
  </PanelLayout>
</template>

<script setup>
import { useUserPreferences } from '@/composables'
import { copyObject } from '@/helpers'
import { computed, ref } from 'vue'
import {
  TIMELINE_TABS,
  TIMELINE_TAB_ALL,
  TIMELINE_TAB_BIOLOGY,
  DEFAULT_TIMELINE_TAB
} from './constants/tabs'
import { CITATIONS_PREVIEW_SIZE } from '../../../constants'
import { useOtuStore } from '../../../store'
import { OTU_SCOPE_ALL } from '../../../constants/otuScope.js'
import {
  matchItem,
  matchBiologyItem,
  itemsForSources,
  itemsForTaxonNames,
  sortChronologically
} from './utils/timelineFilters'
import {
  biologyItems,
  biologySources,
  biologyTopics
} from './utils/biologyItems'
import useOtuTimeline from './composables/useOtuTimeline'
import useOtuBiologyCitations from './composables/useOtuBiologyCitations'
import PanelLayout from '../PanelLayout.vue'
import PanelTimelineTabs from './PanelTimelineTabs.vue'
import PanelTimelineBiology from './PanelTimelineBiology.vue'
import PanelTimelineReferences from './PanelTimelineReferences.vue'
import PanelTimelineSettings from './PanelTimelineSettings.vue'
import TimelineCitations from './PanelTimelineCitations.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    default: 'Timeline'
  }
})

const KEY_STORAGE = 'task::BrowseOtus'

const userPref = useUserPreferences()
const otuStore = useOtuStore()

const preferences = computed(
  () => userPref.preferences.value.layout?.[KEY_STORAGE]
)

const otuRef = computed(() => props.otu)
const { isLoading, timeline, selectedReferenceIds, selectedTopics, tab } =
  useOtuTimeline(otuRef, { defaultTab: DEFAULT_TIMELINE_TAB })
const { isLoading: isBiologyLoading, inventory } =
  useOtuBiologyCitations(otuRef)

const showReferencesTopic = ref(false)
const isModalVisible = ref(false)
const isCitationsExpanded = ref(false)

const alwaysShowAllCitations = computed({
  get: () => preferences.value?.timeline?.alwaysShowAllCitations ?? false,

  set(value) {
    if (!preferences.value) return

    preferences.value.timeline = {
      ...preferences.value.timeline,
      alwaysShowAllCitations: value
    }

    userPref.setPreference(KEY_STORAGE, copyObject(preferences.value))
  }
})

const isBiologyTab = computed(() => tab.value?.kind === TIMELINE_TAB_BIOLOGY)
const isAllTab = computed(() => tab.value?.kind === TIMELINE_TAB_ALL)

const scopedBiologyItems = computed(() =>
  biologyItems(
    inventory.value,
    props.otus.map((otu) => otu.id)
  )
)

const scopedItems = computed(() => {
  const items = timeline.value?.items ?? []

  if (otuStore.otuScope === OTU_SCOPE_ALL) return items

  return itemsForTaxonNames(
    props.otus.map((otu) => otu.taxon_name_id),
    items
  )
})

const matchingItems = computed(() => {
  if (!preferences.value || !timeline.value) return []

  const filterSections = preferences.value.filterSections
  const nomenclatureItems = scopedItems.value.filter((item) =>
    matchItem(item, {
      tab: tab.value,
      filterSections,
      selectedTopics: selectedTopics.value
    })
  )

  if (!isAllTab.value) return nomenclatureItems

  return sortChronologically([
    ...nomenclatureItems,
    ...scopedBiologyItems.value.filter((item) =>
      matchBiologyItem(item, {
        filterSections,
        selectedTopics: selectedTopics.value
      })
    )
  ])
})

const referenceSources = computed(() => {
  const sources = timeline.value?.sources.list ?? {}

  if (!isAllTab.value) return sources

  const merged = { ...biologySources(scopedBiologyItems.value), ...sources }

  return Object.fromEntries(
    Object.entries(merged).sort(
      ([, a], [, b]) => (a.year ?? Infinity) - (b.year ?? Infinity)
    )
  )
})

const referenceTopics = computed(() => {
  const topics = timeline.value?.topics.list ?? {}

  if (!isAllTab.value) return topics

  return {
    ...biologyTopics(scopedBiologyItems.value),
    ...topics
  }
})

const filteredItems = computed(() => {
  if (!selectedReferenceIds.value.length) return matchingItems.value

  return itemsForSources(selectedReferenceIds.value, matchingItems.value)
})

// A long history is trimmed to its first and last citations, which are the ones
// that carry the shape of the nomenclatural story.
const isCollapsible = computed(
  () =>
    !alwaysShowAllCitations.value &&
    filteredItems.value.length > CITATIONS_PREVIEW_SIZE * 2
)

const visibleCitations = computed(() => {
  if (!isCollapsible.value || isCitationsExpanded.value) {
    return filteredItems.value
  }

  return [
    ...filteredItems.value.slice(0, CITATIONS_PREVIEW_SIZE),
    ...filteredItems.value.slice(-CITATIONS_PREVIEW_SIZE)
  ]
})

const hideClasses = computed(() => {
  if (!preferences.value) return {}

  const { show, topic } = preferences.value.filterSections

  return Object.fromEntries(
    [...show, ...topic].map((item) => [item.key, !item.value])
  )
})
</script>

<style lang="scss" scoped>
.hidden {
  display: none;
}
:deep(.modal-container) {
  width: 900px;
}
.topic-section {
  overflow-y: scroll;
  max-height: 480px;
}
.references_topics {
  color: black;
}
:deep(.annotation__note) {
  display: inline;
}
:deep(.hide-validations) {
  .soft_validation_anchor {
    display: none !important;
  }
}
:deep(.hide-notes) {
  .history__citation_notes {
    display: none !important;
  }
}
:deep(.hide-topics) {
  .history__citation_topics {
    display: none !important;
  }
}
</style>
