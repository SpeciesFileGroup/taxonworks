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
            <th>Name</th>
            <th># Couplets</th>
            <th>Is Public</th>
            <th>Last Modified</th>
            <th>Last Modified By</th>
            <th /> <!-- Options button -->
            <th /> <!-- radials -->
          </tr>
          <tr
            v-for="(key, index) in keys"
            :key="key.id"
            :class="{ even: (index % 2 == 0)}"
          >
            <td>{{ key.text }}</td>
            <td>{{ key.couplet_count }}</td>
            <td>{{ key.is_public? 'True' : 'False' }}</td>
            <td>{{ key.updated_at }}</td>
            <td>{{ key.updated_by }}</td>
            <td class="width-shrink">
              <VBtn
                color="primary"
                medium
                @click="() => selectedKey = key"
              >
                Options
              </VBtn>
            </td>
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
    <VModal
      v-if="selectedKey"
      :container-style="{ width: '600px' }"
      @close="() => selectedKey = null"
    >
      <template #header>
        <h1>"{{ leadText(selectedKey) }}" Options</h1>
      </template>
      <template #body>
        <p>
          <a
            :href="RouteNames.NewLead + '?lead_id=' + selectedKey.id"
            target="_blank"
          >
            Edit key
          </a>
        </p>
        <p>
          <a
            :href="RouteNames.ShowLead + '?lead_id=' + selectedKey.id"
            target="_blank"
          >
            Use key
          </a>
        </p>
        <!-- TODO
        <p>
          <a
            href=""
            target="_blank"
          >
            Display entire key on one page
          </a>
        </p>
        <p>
          <a
            href=""
            target="_blank"
          >
            Display entire key on one page for printing
          </a>
        </p>
        ... Download markdown and/or latex versions of the key ...
        -->
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { Lead } from '@/routes/endpoints'
import { leadText } from '../../helpers/formatters.js'
import { onBeforeMount, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const keys = ref([])
const loading = ref(true)
const selectedKey = ref(null)

onBeforeMount(() => {
  Lead.where({ extend: ['couplet_count', 'updater'] })
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
.width-shrink {
  width: 1%;
}
</style>
