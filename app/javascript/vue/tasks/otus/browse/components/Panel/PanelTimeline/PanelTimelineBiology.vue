<template>
  <div>
    <div class="text-base font-bold">Citations ({{ list.length }})</div>
    <div class="margin-medium-top margin-xlarge-bottom">
      <ul class="taxonomic_history no_bullets">
        <li
          v-for="item in list"
          :key="item.id"
          class="margin-small-bottom"
        >
          <PanelTimelineBiologyCitation :item="item" />
        </li>
      </ul>
    </div>
    <template v-if="references.length">
      <div class="text-base font-bold margin-small-bottom">References</div>
      <table class="no_bullets table-striped">
        <thead>
          <tr>
            <th class="w-2"></th>
            <th class="w-2"></th>
            <th>Source</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="source in references"
            :key="source.id"
          >
            <td>
              <input
                v-model="selectedSources"
                :value="source.id"
                class="margin-small-right"
                type="checkbox"
              />
            </td>
            <td>
              <div class="flex-row gap-small">
                <RadialAnnotator :global-id="source.global_id" />
                <RadialNavigator :global-id="source.global_id" />
              </div>
            </td>
            <td>
              <span v-html="source.cached" />
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { getUnique } from '@/helpers'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import PanelTimelineBiologyCitation from './PanelTimelineBiologyCitation.vue'

const props = defineProps({
  items: {
    type: Array,
    required: true
  }
})

const selectedSources = ref([])

const references = computed(() =>
  getUnique(
    props.items.map((item) => item.source),
    'id'
  )
)

const list = computed(() =>
  props.items.filter(
    (item) =>
      !selectedSources.value.length ||
      selectedSources.value.includes(item.source.id)
  )
)
</script>

<style scoped>
td {
  padding: var(--spacing-xs) var(--spacing-xs);
}

td:first-child {
  padding-right: 0;
}
</style>
