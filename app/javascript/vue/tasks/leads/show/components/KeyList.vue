<template>
  <div>
  <VSpinner
    v-if="loading"
    full-screen
    legend="Loading keys..."
    :logo-size="{ width: '100px', height: '100px' }"
  />
  <h1>Available Keys</h1>
  <div class="leads_list">
    <table
      v-if="keys.length > 0"
      class="vue-table"
    >
      <thead>
        <tr>
          <th>Name</th>
          <th># of couplets</th>
          <th>Is Public</th>
          <th>Last Modified</th>
          <th>Last Modified By</th>
          <th /> <!-- radial navigator -->
        </tr>
        <tr
          v-for="(key, index) in keys"
          :key="key.id"
          :class="{ even: (index % 2 == 0)}"
        >
          <td>
            <a
              @click.prevent="() => emit('loadKey', key.id)"
              :href="RouteNames.ShowLead + '?lead_id=' + key.id"
            >
              {{ key.text }}
            </a>
          </td>
          <td>{{ key.couplets_count }}</td>
          <td>{{ key.is_public? 'True' : 'False' }}</td>
          <td>{{ key.key_updated_at_in_words }}</td>
          <td>{{ key.key_updated_by }}</td>
          <td>
            <div class="horizontal-right-content gap-small">
              <RadialNavigator :global-id="key.global_id" />
            </div>
          </td>
        </tr>
      </thead>
    </table>

    <div v-else-if="!loading">
      No key currently available. Use the
      <a
        :href="RouteNames.NewLead"
        data-turbolinks="false"
      >
        New key
      </a>
      task to create one.
    </div>
  </div>
  </div>
</template>

<script setup>
import { Lead } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['loadKey'])

const keys = ref([])
const loading = ref(true)

onBeforeMount(() => {
  Lead.where()
    .then(({ body }) => {
      keys.value = body
    })
    .finally(() => {
      loading.value = false
    })
})
</script>

<style lang="scss" scoped>
.leads_list {
  margin-right: 1em;
  margin-bottom: 2em;
}
</style>