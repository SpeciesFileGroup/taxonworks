<template>
  <PanelLayout
    :title="title"
    :spinner="isLoading"
    menu
    @menu="() => (isModalVisible = true)"
  >
    <template v-if="!isLoading">
      <PanelTimelineTabs
        v-model="tab"
        :tabs="TIMELINE_TABS"
      />

      <PanelTimelineBiology
        v-if="isBiologyTab"
        :otu="otu"
      />

      <template v-else-if="filteredItems.length">
        <div
          v-if="timeline"
          :class="hideClasses"
        >
          <TimelineCitations :citations="filteredItems" />
          <PanelTimelineReferences
            v-model="selectedReferenceIds"
            :sources="timeline.sources.list"
            :topics-list="timeline.topics.list"
            :filtered-items="filteredItems"
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
      :preferences="preferences"
      :nomenclature="timeline"
      @close="() => (isModalVisible = false)"
    />
  </PanelLayout>
</template>

<script setup>
import { useUserPreferences } from '@/composables'
import { computed, ref } from 'vue'
import { TIMELINE_TABS, TIMELINE_TAB_BIOLOGY, DEFAULT_TIMELINE_TAB } from './constants/tabs'
import { matchItem } from './utils/timelineFilters'
import useOtuTimeline from './composables/useOtuTimeline'
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

  title: {
    type: String,
    default: 'Timeline'
  }
})

const KEY_STORAGE = 'task::BrowseOtus'

const userPref = useUserPreferences()

const preferences = computed(
  () => userPref.preferences.value.layout?.[KEY_STORAGE]
)

const otuRef = computed(() => props.otu)
const {
  isLoading,
  timeline,
  selectedReferenceIds,
  selectedTopics,
  tab
} = useOtuTimeline(otuRef, { defaultTab: DEFAULT_TIMELINE_TAB })

const showReferencesTopic = ref(false)
const isModalVisible = ref(false)

const isBiologyTab = computed(() => tab.value?.kind === TIMELINE_TAB_BIOLOGY)

const itemsForSelectedRefs = computed(() => {
  if (!timeline.value) return []
  if (!selectedReferenceIds.value.length) return timeline.value.items

  const objectIds = new Set(
    selectedReferenceIds.value.flatMap(
      (id) => timeline.value.sources.list[id]?.objects ?? []
    )
  )

  return timeline.value.items.filter((item) =>
    objectIds.has(item.data_attributes['history-object-id'])
  )
})

const filteredItems = computed(() => {
  if (!preferences.value || !timeline.value) return []

  return itemsForSelectedRefs.value.filter((item) =>
    matchItem(item, {
      tab: tab.value,
      filterSections: preferences.value.filterSections,
      selectedTopics: selectedTopics.value
    })
  )
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
