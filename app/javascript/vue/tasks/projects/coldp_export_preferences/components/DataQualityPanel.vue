<template>
  <div class="panel padding-large">
    <h2>Missing OTUs</h2>
    <div class="margin-medium-left">
      <div
        v-if="!otuId"
        class="feedback-warning padding-xsmall"
      >
        Save a profile with a root OTU first.
      </div>

      <template v-else>
        <VSpinner v-if="isLoading" />

        <template v-else-if="counts">
          <p class="missing-otus-explanation">
            Valid names without an associated OTU will appear as "bare names" in ChecklistBank and will not be placed in the taxonomic classification.
            Use <a :href="synchronizeOtusPath">Synchronize taxon names to OTUs</a> to fix.
          </p>

          <table class="vue-table missing-otus-table">
            <thead>
              <tr>
                <th>Category</th>
                <th class="num-col">Without OTU</th>
                <th class="num-col">With OTU</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>All names</td>
                <td class="num-col">
                  <b>{{ counts.all_without.toLocaleString() }}</b>
                </td>
                <td class="num-col">{{ counts.all_with.toLocaleString() }}</td>
              </tr>
              <tr>
                <td>All valid</td>
                <td class="num-col">
                  <b>{{ counts.valid_without.toLocaleString() }}</b>
                </td>
                <td class="num-col">{{ counts.valid_with.toLocaleString() }}</td>
              </tr>
              <tr>
                <td>Valid (immediate) children</td>
                <td class="num-col">
                  <b>{{ counts.valid_children_without.toLocaleString() }}</b>
                </td>
                <td class="num-col">{{ counts.valid_children_with.toLocaleString() }}</td>
              </tr>
              <tr>
                <td>All invalid</td>
                <td class="num-col">
                  <b>{{ counts.invalid_without.toLocaleString() }}</b>
                </td>
                <td class="num-col">{{ counts.invalid_with.toLocaleString() }}</td>
              </tr>
              <tr>
                <td>Invalid children</td>
                <td class="num-col">
                  <b>{{ counts.invalid_children_without.toLocaleString() }}</b>
                </td>
                <td class="num-col">{{ counts.invalid_children_with.toLocaleString() }}</td>
              </tr>
            </tbody>
          </table>

          <VBtn
            color="primary"
            class="margin-medium-top"
            :disabled="isLoading"
            @click="loadCounts"
          >
            Refresh
          </VBtn>
        </template>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

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
const counts = ref(null)

const synchronizeOtusPath = '/tasks/taxon_names/synchronize_otus/index'

onMounted(() => {
  if (props.otuId) loadCounts()
})

watch(() => props.otuId, (val) => {
  if (val) loadCounts()
})

async function loadCounts() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.missingOtusCount(
      props.projectId,
      { otu_id: props.otuId }
    )
    counts.value = body
  } catch {
    counts.value = null
  } finally {
    isLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
.missing-otus-explanation {
  color: #888;
  font-size: 0.9em;
  margin-bottom: 0.75em;
}

.missing-otus-table {
  width: 100%;

  th, td {
    padding: 0.4em 0.6em;
  }
}

.num-col {
  width: 8em;
  text-align: right;
}
</style>
