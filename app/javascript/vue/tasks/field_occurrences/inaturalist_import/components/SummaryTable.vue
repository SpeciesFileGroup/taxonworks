<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>Submission summary</h2>
      <VBtn
        color="primary"
        @click="$emit('clear')"
      >
        Clear
      </VBtn>
    </div>

    <table class="full_width">
      <thead>
        <tr>
          <th>iNat observation</th>
          <th>Taxon</th>
          <th>Observer</th>
          <th>Date</th>
          <th>Place</th>
          <th>Images</th>
          <th>Sounds</th>
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
          <td>{{ row.taxon_name }}</td>
          <td>{{ row.observer }}</td>
          <td>{{ row.observed_on }}</td>
          <td>{{ row.place_guess }}</td>
          <td>{{ row.image_count ?? 'n/a' }}</td>
          <td>{{ row.sound_count ?? 'n/a' }}</td>
          <td>
            <span v-if="row.status === 'already_imported'">
              Already imported —
              <a
                :href="row.browse_url"
                target="_blank"
              >view</a>
            </span>
            <span v-else-if="row.status === 'not_found'">Not found on iNaturalist</span>
            <span v-else>Queued</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  rows: {
    type: Array,
    required: true
  }
})

defineEmits(['clear'])

defineOptions({ name: 'SummaryTable' })
</script>
