<template>
  <fieldset>
    <legend>Import Jobs</legend>
    <div>
      <b>No Gazetteers are created until an entire job is completed.</b>
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
                  v-if="true"
                  color="destroy"
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
  </fieldset>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { onMounted, ref } from 'vue'
import { GazetteerImport } from '@/routes/endpoints'

const imports = ref([])

onMounted(() => {
  GazetteerImport.all().then(({ body }) => {
    imports.value = body
  })
})

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

function clearJob(job) {}

</script>

<style lang="scss" scoped>

</style>