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

    <div class="flex-separate middle separate-bottom">
      <VPagination
        :pagination="pagination"
        @next-page="({ page }) => load(page)"
      />
      <PaginationCount
        v-model="perPage"
        :pagination="pagination"
        :max-records="[10, 25, 50, 100]"
        @change="load(1)"
      />
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
import VPagination from '@/components/pagination.vue'
import PaginationCount from '@/components/pagination/PaginationCount.vue'
import { getPagination } from '@/helpers'
import Api from '../api/inaturalist_import.js'

defineOptions({ name: 'RecentImports' })

const fieldOccurrences = ref([])
const isLoading = ref(false)
const perPage = ref(10)
const pagination = ref({})

async function load(page = 1) {
  isLoading.value = true
  try {
    const response = await Api.recent({ page, per_page: perPage.value })
    fieldOccurrences.value = response.body.field_occurrences
    pagination.value = getPagination(response)
  } finally {
    isLoading.value = false
  }
}

onMounted(load)
</script>
