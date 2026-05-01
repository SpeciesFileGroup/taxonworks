<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>Recently imported field occurrences</h2>
      <VBtn
        color="primary"
        :disabled="isLoading"
        @click="load"
      >
        {{ isLoading ? 'Loading…' : 'Refresh' }}
      </VBtn>
    </div>

    <div
      v-if="isLoading"
      class="subtle"
    >
      Loading…
    </div>

    <div
      v-else-if="!fieldOccurrences.length"
      class="subtle"
    >
      No iNaturalist-sourced field occurrences found in this project yet.
    </div>

    <table
      v-else
      class="full_width"
    >
      <thead>
        <tr>
          <th>ID</th>
          <th></th>
          <th>OTU</th>
          <th>Collecting event</th>
          <th>Created</th>
          <th>Images</th>
          <th>Sounds</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="fo in fieldOccurrences"
          :key="fo.id"
        >
          <td>
            <a
              :href="fo.browse_url"
              target="_blank"
            >{{ fo.id }}</a>
          </td>
          <td>
            <a
              v-if="fo.inat_url"
              :href="fo.inat_url"
              target="_blank"
            >iNaturalist</a>
          </td>
          <td v-html="fo.taxon_name" />
          <td>{{ fo.verbatim_locality }}</td>
          <td>{{ fo.created_at }}</td>
          <td>{{ fo.image_count }}</td>
          <td>{{ fo.sound_count }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import Api from '../api/inaturalist_import.js'

defineOptions({ name: 'RecentImports' })

const fieldOccurrences = ref([])
const isLoading = ref(false)

async function load() {
  isLoading.value = true
  try {
    const { body } = await Api.recent()
    fieldOccurrences.value = body.field_occurrences
  } finally {
    isLoading.value = false
  }
}

onMounted(load)
</script>
