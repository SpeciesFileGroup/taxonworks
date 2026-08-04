<template>
  <PanelLayout
    :title="title"
    :spinner="isLoading"
    :empty="!timeline?.items?.length"
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
        :otus="otus"
      />

      <template v-else-if="filteredItems.length">
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
            v-model="selectedReferenceIds"
            :sources="timeline.sources.list"
            :topics-list="timeline.topics.list"
            :filtered-items="visibleCitations"
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
  TIMELINE_TAB_BIOLOGY,
  DEFAULT_TIMELINE_TAB
} from './constants/tabs'
import { CITATIONS_PREVIEW_SIZE } from '../../../constants'
import { matchItem, itemsForSources } from './utils/timelineFilters'
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

const preferences = computed(
  () => userPref.preferences.value.layout?.[KEY_STORAGE]
)

const otuRef = computed(() => props.otu)
const { isLoading, timeline, selectedReferenceIds, selectedTopics, tab } =
  useOtuTimeline(otuRef, { defaultTab: DEFAULT_TIMELINE_TAB })

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

    // A deep plain copy: `setPreference` skips the reference it already holds,
    // and reactive proxies cannot cross the preferences BroadcastChannel.
    userPref.setPreference(KEY_STORAGE, copyObject(preferences.value))
  }
})

const isBiologyTab = computed(() => tab.value?.kind === TIMELINE_TAB_BIOLOGY)

const itemsForSelectedRefs = computed(() => {
  if (!timeline.value) return []
  if (!selectedReferenceIds.value.length) return timeline.value.items

  return itemsForSources(selectedReferenceIds.value, timeline.value.items)
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
