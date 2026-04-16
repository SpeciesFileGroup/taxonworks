<template>
  <div class="text-base font-bold">References</div>
  <ul class="no_bullets">
    <li
      v-for="reference in visibleReferences"
      :key="reference.id"
      class="horizontal-left-content gap-small padding-small-bottom padding-small-top"
    >
      <RadialAnnotator :global-id="reference.id" />
      <RadialNavigation :global-id="reference.id" />
      <label>
        <input
          v-model="selectedIds"
          :value="reference.id"
          class="margin-small-right"
          type="checkbox"
        />
        <span v-html="reference.cached" />
      </label>
      <template v-if="topicsVisible">
        <span
          v-for="topic in reference.topics"
          :key="topic.id"
          class="pill topic references_topics"
          :style="{ 'background-color': topic.css_color }"
          v-html="topic.name"
        />
      </template>
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'
import { sourceHasMatch, sourceTopics } from './utils/timelineFilters'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  sources: {
    type: Object,
    required: true
  },

  topicsList: {
    type: Object,
    required: true
  },

  filteredItems: {
    type: Array,
    required: true
  },

  showTopics: {
    type: Boolean,
    default: false
  }
})

const selectedIds = defineModel({
  type: Array,
  default: () => []
})

const topicsVisible = computed(
  () => props.showTopics && !selectedIds.value.length
)

const allReferences = computed(() =>
  Object.entries(props.sources).map(([id, source]) => ({
    id,
    cached: source.cached,
    source,
    topics: topicsVisible.value
      ? sourceTopics(source, props.filteredItems).map(
          (key) => props.topicsList[key]
        )
      : []
  }))
)

const visibleReferences = computed(() => {
  const matching = allReferences.value.filter((ref) =>
    sourceHasMatch(ref.source, props.filteredItems)
  )

  if (!selectedIds.value.length) return matching

  const selected = new Set(selectedIds.value)

  return matching.filter((ref) => selected.has(ref.id))
})
</script>
