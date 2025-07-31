<template>
  <SectionPanel
    :status="status"
    :spinner="loadState.assertedDistribution"
    :title="title"
  >
    <template #title>
      <a
        v-if="currentOtu"
        :href="`${RouteNames.BrowseAssertedDistribution}?otu_id=${currentOtu.id}`"
        >Expand</a
      >
    </template>
    <TableList
      :list="assertedDistributions"
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
  </SectionPanel>
</template>

<script setup>
import SectionPanel from './shared/sectionPanel'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TableList from './assertedDistribution/TableList.vue'
import { sortArray } from '@/helpers'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { RouteNames } from '@/routes/routes'
import { useStore } from 'vuex'
import { computed, ref } from 'vue'

defineProps({
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
  }
})

const COLUMNS = [
  'level0',
  'level1',
  'level2',
  'name',
  'type',
  'presence',
  'shape',
  'citations',
  'otu'
]

const store = useStore()
const ascending = ref(false)

const loadState = computed(() => store.getters[GetterNames.GetLoadState])

const assertedDistributions = computed({
  get: () => store.getters[GetterNames.GetAssertedDistributions],
  set: (value) => store.commit(MutationNames.SetAssertedDistributions, value)
})

const currentOtu = computed(() => store.getters[GetterNames.GetCurrentOtu])

function sortTable(sortProperty) {
  assertedDistributions.value = sortArray(
    assertedDistributions.value,
    sortProperty,
    ascending.value,
    { stripHtml: true }
  )

  ascending.value = !ascending.value
}
</script>
