<template>
  <PanelLayout
    :status="status"
    :spinner="isLoading"
    :title="title"
  >
    <template #title>
      <a
        v-if="currentOtu"
        :href="`${RouteNames.BrowseAssertedDistribution}?otu_id=${currentOtu.id}`"
        >Expand</a
      >
    </template>
    <div class="overflow-x-auto">
      <TableList
        v-if="list.length"
        :list="list"
        :columns="COLUMNS"
        @sort="sortTable"
      >
        <template #citations="{ column }">
          <div class="flex-row gap-small middle">
            Citations
            <VBtn
              title="Sort alphabetically"
              color="primary"
              circle
              @click.stop="() => sortTable(column)"
            >
              <VIcon
                name="alphabeticalSort"
                title="Sort alphabetically"
                x-small
              />
            </VBtn>
            <VBtn
              color="primary"
              circle
              title="Sort by year"
              @click.stop="() => sortTable('year')"
            >
              <VIcon
                name="numberSort"
                title="Sort by year"
                x-small
              />
            </VBtn>
          </div>
        </template>
      </TableList>
      <div v-else>No asserted distributions available</div>
    </div>
  </PanelLayout>
</template>

<script setup>
import PanelLayout from '../PanelLayout.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TableList from './PanelAssertedDistributionTable.vue'
import { sortArray } from '@/helpers'
import { AssertedDistribution } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { computed, ref, watch } from 'vue'
import listParser from '@/tasks/otu/browse_asserted_distributions/helpers/listParser.js'

const props = defineProps({
  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: undefined
  },

  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  }
})

const EMBED = ['level_names']

const EXTEND = [
  'citations',
  'asserted_distribution_shape',
  'shape_type',
  'origin_citation',
  'source',
  'asserted_distribution_object'
]

const COLUMNS = [
  'level0',
  'level1',
  'level2',
  'name',
  'shape type',
  'presence',
  'shape',
  'citations',
  'object',
  'object type'
]

const ascending = ref(false)
const isLoading = ref(false)
const list = ref([])

const currentOtu = computed(() => props.otu)

function sortTable(sortProperty) {
  list.value = sortArray(list.value, sortProperty, ascending.value, {
    stripHtml: true
  })

  ascending.value = !ascending.value
}

async function loadAssertedDistrbutions(otuIds) {
  isLoading.value = true
  try {
    const { body } = await AssertedDistribution.all({
      otu_id: otuIds,
      embed: EMBED,
      extend: EXTEND
    })
    list.value = listParser(body)
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      const otuIds = newVal.map((o) => o.id)

      loadAssertedDistrbutions(otuIds)
    }
  },
  { immediate: true }
)
</script>
