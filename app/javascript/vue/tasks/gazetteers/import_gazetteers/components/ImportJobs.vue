<template>
   <BlockLayout
    expand
    class="status"
  >
    <template #header>
      <div class="header middle">
        <h3>Import Jobs Status</h3>
        <div class="header-buttons">
          <VBtn
            color="primary"
            circle
            @click="refresh()"
          >
            <VIcon
              name="reset"
              x-small
            />
          </VBtn>
        </div>
        <div class="header-right">
          <a href="/gazetteers">Gazetteers</a>
        </div>
      </div>
    </template>

    <template #body>
      <VSpinner v-if="statusLoading" />
      <div>
        Deleting job status records here has no effect on any import.
      </div>
      <div class="vue-table-container">
        <table class="vue-table">
          <thead>
            <tr>
              <th class="word-keep-all">Shapefile</th>
              <th class="word-keep-all">Submitted by</th>
              <th class="word-keep-all">Status</th>
              <th class="word-keep-all">Number of shapefile records</th>
              <th class="word-keep-all">Number of gazetteers imported</th>
              <th class="word-keep-all">Projects Imported to</th>
              <th class="word-keep-all">Import errors</th>
              <th class="word-keep-all">Start time</th>
              <th class="word-keep-all">End time</th>
              <th class="word-keep-all"></th>
            </tr>
          </thead>
          <TransitionGroup
            name="list-complete"
            tag="tbody"
          >
            <tr
              v-for="job in imports"
              :key="job.id"
              class="list-complete-item"
            >
              <td class="word-keep-all">{{ job['shapefile'] }}</td>
              <td>{{ job['submitted_by'] }}</td>
              <td>{{ jobStatus(job) }}</td>
              <td>{{ job['num_records'] }}</td>
              <td>{{ job['num_records_imported'] }}</td>
              <td>{{ job['project_names'] }}</td>
              <td>{{ job['error_messages'] }}</td>
              <td>{{ job['started_at'] }}</td>
              <td>{{ job['ended_at'] }}</td>
              <td>
                <div class="horizontal-right-content gap-small">
                  <VBtn
                    v-if="completed(job)"
                    color="primary"
                    circle
                    @click="clearJob(job)"
                  >
                    <VIcon
                      name="trash"
                      x-small
                    />
                  </VBtn>
                </div>
              </td>
            </tr>
          </TransitionGroup>
        </table>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner'
import { onMounted, ref } from 'vue'
import { GazetteerImport } from '@/routes/endpoints'
import { removeFromArray } from '@/helpers/arrays'

const imports = ref([])
const statusLoading = ref(false)

onMounted(() => {
  refresh()
})

function refresh() {
  statusLoading.value = true
  GazetteerImport.all().then(({ body }) => {
    imports.value = body
  })
  .finally(() => { statusLoading.value = false })
}

function jobStatus(job) {
  if (!job['num_records']) {
    return 'Starting...'
  } else if (!job['ended_at']) {
    return 'Running'
  } else {
    return 'Completed'
  }
}

function completed(job) {
  return !!job['ended_at'] || job['aged']
}

function clearJob(job) {
  const job_id = job.id
  removeFromArray(imports.value, job)

  GazetteerImport.destroy(job_id)
}

defineExpose({
  refresh
})

</script>

<style lang="scss" scoped>
.status {
  margin-bottom: 2em;
}
.header {
  display: flex;
  flex-grow: 2;
}
.header-buttons {
  margin-left: .5em;
}
.header-right {
  flex-grow: 2;
  text-align: end;
  margin-right: 1.5em;
}
</style>