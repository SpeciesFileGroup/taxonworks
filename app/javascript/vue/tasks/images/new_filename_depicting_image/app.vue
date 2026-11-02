<template>
  <div class="margin-medium-top">
    <div class="filename-depiction-layout">
      <PanelPattern />
      <BlockLayout :warning="!!store.failedRows.length">
        <template #header>
          <h3>Images</h3>
        </template>
        <template #body>
          <div class="flex-col gap-medium">
            <FileDropzone
              ref="dropzoneRef"
              @complete="notifyCompletion"
            />
            <template v-if="store.rows.length">
              <FilesSummary
                v-model:filter="filter"
                @upload="upload"
                @retry="retry"
                @reset="reset"
              />
              <FilesTable
                :rows="filteredRows"
                @remove="removeRow"
              />
            </template>
          </div>
        </template>
      </BlockLayout>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, useTemplateRef } from 'vue'
import { useStore } from './store/store'
import { STATUS } from './constants'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PanelPattern from './components/Pattern/PanelPattern.vue'
import FileDropzone from './components/Files/FileDropzone.vue'
import FilesSummary from './components/Files/FilesSummary.vue'
import FilesTable from './components/Files/FilesTable.vue'

const store = useStore()
const dropzoneRef = useTemplateRef('dropzoneRef')

const filter = ref('all')

const filteredRows = computed(() =>
  filter.value === 'all'
    ? store.rows
    : store.rows.filter((row) => store.rowStatus(row) === filter.value)
)

function upload() {
  const rows = [...store.uploadableRows]

  store.queueRows(rows)
  rows.forEach((row) => dropzoneRef.value.enqueue(row.file))
}

function retry() {
  const rows = store.failedRows.filter((row) => row.file.accepted)

  store.queueRows(rows)
  rows.forEach((row) => dropzoneRef.value.enqueue(row.file))
}

function removeRow(row) {
  dropzoneRef.value.remove(row.file)
  store.removeRow(row)
}

function reset() {
  dropzoneRef.value.removeAll()
  store.reset()
  filter.value = 'all'
}

function notifyCompletion() {
  const counts = store.statusCounts
  const created = counts[STATUS.Created] || 0
  const alreadyDepicted = counts[STATUS.AlreadyDepicted] || 0
  const failed = counts[STATUS.Error] || 0

  if (!created && !alreadyDepicted && !failed) return

  TW.workbench.alert.create(
    `Upload finished: ${created} depictions created, ${alreadyDepicted} already depicted, ${failed} failed.`,
    failed ? 'error' : 'notice'
  )
}
</script>

<style scoped>
.filename-depiction-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 2fr);
  gap: 1rem;
  align-items: start;
}
</style>
