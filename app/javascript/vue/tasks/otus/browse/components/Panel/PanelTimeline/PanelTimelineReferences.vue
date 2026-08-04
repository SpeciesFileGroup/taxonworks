<template>
  <div class="text-base font-bold margin-small-bottom">References</div>
  <table class="no_bullets table-striped">
    <thead>
      <tr>
        <th class="w-2"></th>
        <th class="w-2"></th>
        <th>Source</th>
        <th v-if="topicsVisible">Topic</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="reference in visibleReferences"
        :key="reference.id"
      >
        <td>
          <input
            v-model="selectedIds"
            :value="reference.id"
            class="margin-small-right"
            type="checkbox"
          />
        </td>
        <td>
          <div class="flex-row gap-small">
            <RadialAnnotator :global-id="reference.id" />
            <RadialNavigation :global-id="reference.id" />
          </div>
        </td>
        <td>
          <span v-html="reference.cached" />
        </td>
        <td v-if="topicsVisible">
          <span
            v-for="topic in reference.topics"
            :key="topic.id"
            class="pill topic references_topics"
            :style="{ 'background-color': topic.css_color }"
            v-html="topic.name"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { citedSourceIds, sourceTopics } from './utils/timelineFilters'
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

const citedIds = computed(() => citedSourceIds(props.filteredItems))

const allReferences = computed(() =>
  Object.entries(props.sources).map(([id, source]) => ({
    id,
    cached: source.cached,
    source,
    topics: topicsVisible.value
      ? sourceTopics(id, props.filteredItems).map(
          (key) => props.topicsList[key]
        )
      : []
  }))
)

const visibleReferences = computed(() => {
  const matching = allReferences.value.filter((ref) =>
    citedIds.value.has(ref.id)
  )

  if (!selectedIds.value.length) return matching

  const selected = new Set(selectedIds.value)

  return matching.filter((ref) => selected.has(ref.id))
})
</script>

<style scoped>
td {
  padding: var(--spacing-xs) var(--spacing-xs);
}

td:first-child {
  padding-right: 0;
}
</style>
