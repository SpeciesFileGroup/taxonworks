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
      </div>
    </template>

    <template #body>
      <VSpinner v-if="status_loading" />
      <div>
        <b>No Gazetteers are created until the job status is 'Completed'</b>,
        at which time the job record here can be deleted.
      </div>
      <div class="vue-table-container">
        <table class="vue-table">
          <thead>
            <tr>
              <th class="word-keep-all">Shapefile</th>
              <th class="word-keep-all">Status</th>
              <th class="word-keep-all">Gazetteers Imported</th>
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
              <td>{{ jobStatus(job) }}</td>
              <td>{{ gzsImported(job) }}</td>
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
const status_loading = ref(false)

onMounted(() => {
  refresh()
})

function refresh() {
  status_loading.value = true
  GazetteerImport.all().then(({ body }) => {
    imports.value = body
  })
  .finally(() => { status_loading.value = false })
}

function jobStatus(job) {
  if (!job['num_records']) {
    return 'Starting...'
  } else if (!job['ended_at']) {
    return 'Running'
  } else if (!job['aborted_reason']) {
    return 'Completed'
  } else {
    return 'Aborted, no Gazetteers saved: ' + job['aborted_reason']
  }
}

function gzsImported(job) {
  if (job['ended_at'] && !job['aborted_reason']) {
    return job['num_records']
  } else {
    return ''
  }
}

function completed(job) {
  return !!job['ended_at']
}

function clearJob(job) {
  const job_id = job.id
  removeFromArray(imports.value, job)

  GazetteerImport.destroy(job_id)
}

</script>

<style lang="scss" scoped>
.status {
  margin-bottom: 2em;
}
.header {
  display: flex;
}
.header-buttons {
  margin-left: .5em;
}
</style>