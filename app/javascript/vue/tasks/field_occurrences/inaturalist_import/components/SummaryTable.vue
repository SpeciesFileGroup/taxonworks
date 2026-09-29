<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>{{ localFindMode ? 'Search results' : 'Submission summary' }}</h2>
      <div class="horizontal-right-content gap-small">
        <VBtn
          v-if="selectableIds.length"
          color="primary"
          :disabled="!selectedIds.length"
          @click="isDeterminationModalVisible = true"
        >
          Set determination
        </VBtn>
        <VBtn
          v-if="foundIds.length"
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

    <VModal
      v-if="isDeterminationModalVisible"
      @close="isDeterminationModalVisible = false"
    >
      <template #header>
        <h3>
          Set determination on {{ selectedIds.length }} field
          occurrence{{ selectedIds.length === 1 ? '' : 's' }}
        </h3>
      </template>
      <template #body>
        <TaxonDeterminationForm
          create-form
          button-label="Set"
          @on-add="setDetermination"
        />
      </template>
    </VModal>

    <table class="full_width table-striped">
      <thead>
        <tr>
          <th class="w-2">
            <input
              v-if="selectableIds.length"
              type="checkbox"
              title="Select all"
              :checked="areAllSelected"
              @change="toggleAll"
            />
          </th>
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
            <input
              v-if="row.field_occurrence_id"
              v-model="selectedIds"
              type="checkbox"
              :value="row.field_occurrence_id"
            />
          </td>
          <td>
            <a
              :href="`https://www.inaturalist.org/observations/${row.observation_id}`"
              target="_blank"
            >
              {{ row.observation_id }}
            </a>
          </td>
          <td
            v-if="row.determination_label"
            v-html="row.determination_label"
          />
          <td v-else>{{ row.taxon_name }}</td>
          <td>{{ row.observer }}</td>
          <td>{{ row.observed_on }}</td>
          <td>{{ row.place_guess }}</td>
          <td>{{ row.image_count ?? 'n/a' }}</td>
          <td>{{ row.sound_count ?? 'n/a' }}</td>
          <td>
            <FieldOccurrenceLink
              v-if="row.status === INAT_STATUS_FOUND || row.status === INAT_STATUS_CREATED"
              :browse-url="row.browse_url"
              :global-id="row.global_id"
              :determination-label="row.determination_label"
              @quick-forms-change="(event) => onQuickFormsChange(row.uuid, event)"
            />
            <span v-else-if="row.status === INAT_STATUS_NOT_IMPORTED">{{ localFindMode ? 'Not imported' : 'Queued' }}</span>
            <div
              v-else-if="row.status === INAT_STATUS_ALREADY_IMPORTED"
              class="flex-row gap-small middle"
            >
              <span>Already imported —</span>
              <FieldOccurrenceLink
                :browse-url="row.browse_url"
                :global-id="row.global_id"
                :determination-label="row.determination_label"
                @quick-forms-change="(event) => onQuickFormsChange(row.uuid, event)"
              />
            </div>
            <span v-else-if="row.status === INAT_STATUS_NOT_FOUND">Not found on iNaturalist</span>
            <span v-else-if="row.status === INAT_STATUS_NO_TAXON">No taxon — skipped</span>
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
import VModal from '@/components/ui/Modal.vue'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import FieldOccurrenceLink from './FieldOccurrenceLink.vue'
import { FieldOccurrence, TaxonDetermination } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import {
  INAT_STATUS_FOUND,
  INAT_STATUS_CREATED,
  INAT_STATUS_NOT_IMPORTED,
  INAT_STATUS_ALREADY_IMPORTED,
  INAT_STATUS_NOT_FOUND,
  INAT_STATUS_NO_TAXON
} from '../constants/importStatuses.js'

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
const selectedIds = ref([])
const isDeterminationModalVisible = ref(false)

watch(() => props.rows, rows => {
  localRows.value = [...rows]
  selectedIds.value = []
})
watch(() => props.findMode, mode => { localFindMode.value = mode })

const foundIds = computed(() =>
  localRows.value
    .filter(r => r.status === INAT_STATUS_FOUND || r.status === INAT_STATUS_CREATED)
    .map(r => r.field_occurrence_id)
    .filter(Boolean)
)

// Rows with a field occurrence (not queued ones) can be determined.
const selectableIds = computed(() =>
  localRows.value.map((r) => r.field_occurrence_id).filter(Boolean)
)

const areAllSelected = computed(() =>
  selectableIds.value.length > 0 &&
  selectableIds.value.every((id) => selectedIds.value.includes(id))
)

function toggleAll() {
  selectedIds.value = areAllSelected.value ? [] : [...selectableIds.value]
}

// Adds the determination on top of each selected field occurrence's existing
// ones, making it current.
function setDetermination(taxonDetermination) {
  const fieldOccurrenceIds = [...selectedIds.value]
  const uuids = localRows.value
    .filter((r) => fieldOccurrenceIds.includes(r.field_occurrence_id))
    .map((r) => r.uuid)

  TaxonDetermination.createBatch({
    taxon_determination: taxonDetermination,
    field_occurrence_id: fieldOccurrenceIds
  })
    .then(({ body }) => {
      isDeterminationModalVisible.value = false
      selectedIds.value = []
      refreshRows(uuids)

      if (body.failed.length) {
        TW.workbench.alert.create(
          `${body.total_created} determined, ${body.failed.length} failed.`,
          'error'
        )
      } else {
        TW.workbench.alert.create(
          `${body.total_created} determined.`,
          'notice'
        )
      }
    })
    .catch(() => {})
}

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

function onQuickFormsChange(uuid, { slice }) {
  if (slice === 'taxon_determinations') {
    refreshRows([uuid])
  }
}

// Replace just these rows in place, keeping their status.
async function refreshRows(uuids) {
  try {
    const { body } = await FieldOccurrence.iNatCheckForExisting({ uuids })
    body.found.forEach((updated) => {
      const index = localRows.value.findIndex((r) => r.uuid === updated.uuid)
      if (index !== -1) {
        localRows.value[index] = { ...localRows.value[index], ...updated }
      }
    })
  } catch {}
}

function sendToFilter() {
  const params = foundIds.value.map(id => `field_occurrence_id[]=${id}`).join('&')
  window.open(`${RouteNames.FilterFieldOccurrence}?${params}`, '_blank')
}
</script>
