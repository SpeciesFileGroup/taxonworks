<template>
  <div class="ba-related">
    <div class="ba-related__header">
      <h3 class="ba-related__title">Related</h3>
      <VSwitch
        v-if="pagination.total"
        v-model="view"
        :options="VIEWS"
      />
    </div>

    <VSkeleton
      v-if="!isInitialized"
      variant="rect"
      height="360px"
    />

    <div v-else-if="!pagination.total">No related associations found.</div>

    <template v-else-if="view === TABLE_VIEW">
      <div class="overflow-x-auto">
        <PanelBiologicalAssociationsTable
          :list="list"
          @open-detail="emit('open-detail', $event)"
        />
      </div>
      <div class="ba-related__pagination">
        <VPagination
          v-if="pagination.totalPages > 1"
          :pagination="pagination"
          @next-page="({ page }) => loadPage(page)"
        />
        <PaginationCount
          v-model="perPage"
          :pagination="pagination"
        />
      </div>
    </template>

    <VSkeleton
      v-else-if="isLoadingGraph"
      variant="rect"
      height="560px"
    />

    <PanelBiologicalAssociationsNetwork
      v-else
      :list="records"
    />
  </div>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import PanelBiologicalAssociationsNetwork from './PanelBiologicalAssociationsNetwork.vue'
import PanelBiologicalAssociationsTable from './PanelBiologicalAssociationsTable.vue'
import PaginationCount from '@/components/pagination/PaginationCount.vue'
import VPagination from '@/components/pagination.vue'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import getPagination from '@/helpers/getPagination'
import { listAdapter, EXTEND } from './utils/listAdapter.js'

const GRAPH_EXTEND = ['subject', 'object', 'biological_relationship']
const TABLE_VIEW = 'Table'
const GRAPH_VIEW = 'Graph'
const VIEWS = [TABLE_VIEW, GRAPH_VIEW]

const props = defineProps({
  association: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['open-detail'])

const view = ref(TABLE_VIEW)

const list = ref([])
const pagination = ref({})
const isInitialized = ref(false)
const perPage = ref(50)

const records = ref([])
const isLoadingGraph = ref(false)
const isGraphLoaded = ref(false)

function idParams() {
  const { subjectType, subjectId, objectType, objectId } = props.association
  const params = {}

  for (const [type, id] of [
    [subjectType, subjectId],
    [objectType, objectId]
  ]) {
    const param = ID_PARAM_FOR[type]

    params[param] = [...(params[param] || []), id]
  }

  return params
}

async function loadPage(page) {
  try {
    const response = await BiologicalAssociation.where({
      ...idParams(),
      extend: EXTEND,
      page,
      per: Number(perPage.value)
    })

    list.value = await listAdapter(response.body)
    pagination.value = getPagination(response)
  } catch {
  } finally {
    isInitialized.value = true
  }
}

/** The graph needs every association at once; loaded on demand. */
async function loadGraph() {
  isLoadingGraph.value = true

  try {
    const { body } = await BiologicalAssociation.all({
      ...idParams(),
      extend: GRAPH_EXTEND
    })

    records.value = body
    isGraphLoaded.value = true
  } catch {
  } finally {
    isLoadingGraph.value = false
  }
}

onBeforeMount(() => loadPage(1))

watch(view, (newView) => {
  if (newView === GRAPH_VIEW && !isGraphLoaded.value) {
    loadGraph()
  }
})

watch(perPage, () => loadPage(1))
</script>

<style scoped>
.ba-related {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.ba-related__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.ba-related__title {
  margin: 0;
}

.ba-related__pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 16px;
}
</style>
