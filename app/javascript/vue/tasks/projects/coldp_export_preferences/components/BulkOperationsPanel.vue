<template>
  <div class="panel padding-large">
    <h2>Bulk Operations</h2>
    <div class="margin-medium-left">
      <div
        v-if="!otuId"
        class="feedback-warning padding-xsmall"
      >
        Save a profile with a root OTU first.
      </div>

      <template v-else>
        <p class="bulk-ops-note">These operations are queued as background jobs and may take a while to complete. You may need to wait until these jobs complete before doing an export.</p>

        <div class="operation">
          <h3>Set fossils as extinct</h3>
          <p class="bulk-ops-note">Nomenclatural fossil status alone does not mark a taxon as extinct, since some paleotaxa may be extant. This operation sets the ColDP extinct attribute on OTUs for fossils that lack one.</p>
          <label class="margin-small-right">
            <input
              type="radio"
              v-model="extinctOverwrite"
              :value="false"
            />
            Skip existing
          </label>
          <label>
            <input
              type="radio"
              v-model="extinctOverwrite"
              :value="true"
            />
            Overwrite
          </label>
          <br>
          <VBtn
            color="create"
            class="margin-small-top"
            @click="bulkSetExtinct"
            :disabled="isLoading"
          >
            Set fossils extinct
          </VBtn>
        </div>

        <div class="operation margin-large-top">
          <h3>Set lifezone</h3>
          <label>
            Value:
            <select v-model="lifezoneValue" class="margin-small-left">
              <option value="terrestrial">terrestrial</option>
              <option value="marine">marine</option>
              <option value="freshwater">freshwater</option>
              <option value="brackish">brackish</option>
            </select>
          </label>
          <br>
          <label class="margin-small-right">
            <input
              type="radio"
              v-model="lifezoneOverwrite"
              :value="false"
            />
            Skip existing
          </label>
          <label>
            <input
              type="radio"
              v-model="lifezoneOverwrite"
              :value="true"
            />
            Overwrite
          </label>
          <br>
          <VBtn
            color="create"
            class="margin-small-top"
            @click="bulkSetLifezone"
            :disabled="isLoading"
          >
            Set lifezone
          </VBtn>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  },
  otuId: {
    type: Number,
    default: null
  }
})

const isLoading = ref(false)
const extinctOverwrite = ref(false)
const lifezoneValue = ref('terrestrial')
const lifezoneOverwrite = ref(false)

async function bulkSetExtinct() {
  if (!confirm('This will set extinct on all fossil OTUs in the subtree. Continue?')) return

  isLoading.value = true
  try {
    await ColdpExportPreference.bulkSetExtinct(props.projectId, {
      otu_id: props.otuId,
      overwrite: extinctOverwrite.value
    })
    TW.workbench.alert.create('Bulk extinct job enqueued.', 'notice')
  } catch {
    TW.workbench.alert.create('Failed to enqueue job', 'error')
  } finally {
    isLoading.value = false
  }
}

async function bulkSetLifezone() {
  if (!confirm(`This will set lifezone to "${lifezoneValue.value}" on all OTUs in the subtree. Continue?`)) return

  isLoading.value = true
  try {
    await ColdpExportPreference.bulkSetLifezone(props.projectId, {
      otu_id: props.otuId,
      value: lifezoneValue.value,
      overwrite: lifezoneOverwrite.value
    })
    TW.workbench.alert.create('Bulk lifezone job enqueued.', 'notice')
  } catch {
    TW.workbench.alert.create('Failed to enqueue job', 'error')
  } finally {
    isLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
.bulk-ops-note {
  color: #888;
  font-size: 0.9em;
  margin-bottom: 0.75em;
}

.operation {
  padding-bottom: 1em;
  border-bottom: 1px solid var(--border-color);
}
</style>
