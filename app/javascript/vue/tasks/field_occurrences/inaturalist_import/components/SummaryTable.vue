<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>{{ isFindMode ? 'Search results' : 'Submission summary' }}</h2>
      <div class="horizontal-right-content">
        <VBtn
          v-if="isFindMode && foundIds.length"
          color="primary"
          @click="sendToFilter"
          class="margin-medium-right"
        >
          Send to filter
        </VBtn>
        <VBtn
          color="primary"
          @click="$emit('clear')"
        >
          Clear
        </VBtn>
      </div>
    </div>

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
          v-for="row in rows"
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
            <span v-else-if="row.status === 'not_imported'">Not yet imported</span>
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
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  }
})

defineEmits(['clear'])

defineOptions({ name: 'SummaryTable' })

const isFindMode = computed(() =>
  props.rows.some(r => r.status === 'found' || r.status === 'not_imported')
)

const foundIds = computed(() =>
  props.rows.filter(r => r.status === 'found').map(r => r.field_occurrence_id)
)

function sendToFilter() {
  const params = foundIds.value.map(id => `field_occurrence_id[]=${id}`).join('&')
  window.open(`${RouteNames.FilterFieldOccurrence}?${params}`, '_blank')
}
</script>
