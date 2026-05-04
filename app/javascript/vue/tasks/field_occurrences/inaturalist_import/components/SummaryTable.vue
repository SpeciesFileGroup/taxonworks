<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>{{ localFindMode ? 'Search results' : 'Submission summary' }}</h2>
      <div class="horizontal-right-content gap-small">
        <VBtn
          v-if="localFindMode && foundIds.length"
          color="primary"
          @click="sendToFilter"
        >
          Send to filter
        </VBtn>
        <VBtn
          v-if="localRows.length"
          color="primary"
          :disabled="isRefreshing"
          @click="refresh"
        >
          Refresh
        </VBtn>
        <VBtn
          color="primary"
          @click="() => { emit('clear') }"
        >
          Clear
        </VBtn>
      </div>
    </div>

    <p
      v-if="!localFindMode"
      class="subtle"
    >
      Observations are imported in the background. Use Refresh to check progress.
    </p>

    <table class="full_width table-striped">
      <thead>
        <tr>
          <th>iNat observation</th>
          <th>Taxon</th>
          <th>Observer</th>
          <th>Date</th>
          <th>Place</th>
          <th>CC Images</th>
          <th>CC Sounds</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="row in localRows"
          :key="row.observation_id"
        >
          <td>
            <a
              :href="`https://www.inaturalist.org/observations/${row.observation_id}`"
              target="_blank"
            >
              {{ row.observation_id }}
            </a>
          </td>
          <td
            v-if="row.field_occurrence_id"
            v-html="row.taxon_name"
          />
          <td v-else>{{ row.taxon_name }}</td>
          <td>{{ row.observer }}</td>
          <td>{{ row.observed_on }}</td>
          <td>{{ row.place_guess }}</td>
          <td>{{ row.image_count ?? 'n/a' }}</td>
          <td>{{ row.sound_count ?? 'n/a' }}</td>
          <td>
            <a
              v-if="row.status === 'found'"
              :href="row.browse_url"
              target="_blank"
            >Found</a>
            <a
              v-else-if="row.status === 'created'"
              :href="row.browse_url"
              target="_blank"
            >Created</a>
            <span v-else-if="row.status === 'not_imported'">Queued</span>
            <span v-else-if="row.status === 'already_imported'">
              Already imported —
              <a
                :href="row.browse_url"
                target="_blank"
              >view</a>
            </span>
            <span v-else-if="row.status === 'not_found'">Not found on iNaturalist</span>
            <span v-else-if="row.status === 'no_taxon'">No taxon — skipped</span>
            <span v-else>Queued</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { FieldOccurrence } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },
  findMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['clear'])

defineOptions({ name: 'SummaryTable' })

const localRows = ref([...props.rows])
const localFindMode = ref(props.findMode)
const isRefreshing = ref(false)

watch(() => props.rows, rows => { localRows.value = [...rows] })
watch(() => props.findMode, mode => { localFindMode.value = mode })

const foundIds = computed(() =>
  localRows.value.filter(r => r.status === 'found').map(r => r.field_occurrence_id)
)

async function refresh() {
  const uuids = localRows.value.filter(r => r.uuid).map(r => r.uuid)
  if (!uuids.length) return

  isRefreshing.value = true
  try {
    const { body } = await FieldOccurrence.iNatCheckForExisting({ uuids })
    const foundByUuid = Object.fromEntries(body.found.map(f => [f.uuid, f]))
    localRows.value = localRows.value.map(row => {
      const match = row.uuid && foundByUuid[row.uuid]
      return match ? { ...row, ...match, status: 'created' } : row
    })
  } catch {
  } finally {
    isRefreshing.value = false
  }
}

function sendToFilter() {
  const params = foundIds.value.map(id => `field_occurrence_id[]=${id}`).join('&')
  window.open(`${RouteNames.FilterFieldOccurrence}?${params}`, '_blank')
}
</script>
