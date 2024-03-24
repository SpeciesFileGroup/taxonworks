<template>
  <div>
    <VSpinner
      v-if="loading"
      legend="Loading keys..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <h3 class="title-section">Keys</h3>
    <div class="leads_list">
      <table
        v-if="keys.length"
        class="vue-table"
      >
        <thead>
          <tr>
            <th @click="() => sortTable('text')">
              Name
            </th>
            <th @click="() => sortTable('couplet_count')">
              # Couplets
            </th>
            <th @click="() => sortTable('is_public')">
              Is Public
            </th>
            <th @click="() => sortTable('updated_at')">
              Last Modified
            </th>
            <th @click="() => sortTable('updated_by')">
              Last Modified By
            </th>
            <th /> <!-- radials -->
          </tr>
          <tr
            v-for="(key, index) in keys"
            :key="key.id"
            :class="{ even: (index % 2 == 0)}"
          >
            <td>{{ key.text }}</td>
            <td>{{ key.couplet_count }}</td>
            <td>
              <input
                type="checkbox"
                :checked="key.is_public"
                @click="() => changeIsPublicState(key)"
              />
            </td>
            <td>{{ key.updated_at_in_words }}</td>
            <td>{{ key.updated_by }}</td>
            <td class="width-shrink">
              <div class="horizontal-right-content gap-small">
                <RadialAnnotator :global-id="key.global_id" />
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
          New dichotomous key
        </a>
        task to create one.
      </div>
    </div>
  </div>
</template>

<script setup>
import { addToArray } from '@/helpers/arrays'
import { Lead } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { sortArray } from '@/helpers'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const keys = ref([])
const loading = ref(true)
const ascending = ref(false)

onBeforeMount(() => {
  Lead.where({ extend: ['couplet_count', 'updater', 'updated_at_in_words'] })
    .then(({ body }) => {
      keys.value = body
    })
    .finally(() => {
      loading.value = false
    })
})

function sortTable(sortProperty) {
  keys.value = sortArray(keys.value, sortProperty, ascending.value)
  ascending.value = !ascending.value
}

function changeIsPublicState(key) {
  const payload = {
    lead: {
      is_public: !key.is_public
    },
    extend: ['couplet_count', 'updater', 'updated_at_in_words']
  }

  Lead.update_meta(key.id, payload)
    .then(({ body }) => {
      addToArray(keys.value, body.lead)
    })
    .catch(() => {})
}
</script>

<style lang="scss" scoped>
.leads_list {
  margin-right: 1em;
  margin-bottom: 2em;
}
.width-shrink {
  width: 1%;
}
</style>
