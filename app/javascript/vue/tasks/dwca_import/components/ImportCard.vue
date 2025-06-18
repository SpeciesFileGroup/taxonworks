<template>
  <div
    class="panel cursor-pointer import-card padding-large-left padding-large-right padding-large-bottom padding-medium-top"
    @click="emit('onSelect', dataset.id)"
  >
    <h3 class="flex-separate middle gap-small">
      <b
        class="text-ellipsis"
        :title="dataset.description"
      >
        {{ dataset.description }}
      </b>
      <div class="horizontal-right-content gap-small">
        <VBtn
          circle
          color="primary"
          :href="dataset.source_file"
          title="Download original"
        >
          <VIcon
            color="white"
            x-small
            name="download"
            title="Download original"
          />
        </VBtn>

        <VBtn
          circle
          color="destroy"
          @click.stop="destroyDataset(dataset)"
        >
          <VIcon
            name="trash"
            x-small
          />
        </VBtn>
      </div>
    </h3>

    <div class="flex-col margin-small-top">
      <span>DwC-A {{ dataset.type.split('::').pop() }}</span>
      <span
        >Status: <b>{{ dataset.status }}</b></span
      >
      <span
        >Created at: <b>{{ formatDate(new Date(dataset.created_at)) }}</b></span
      >
      <span
        >Updated at: <b>{{ formatDate(new Date(dataset.updated_at)) }}</b></span
      >
    </div>
    <hr class="divisor full_width margin-medium-top margin-medium-bottom" />
    <progress-bar
      class="full_width"
      :progress="dataset.progress"
    />
    <progress-list
      table-mode
      :progress="dataset.progress"
    />
  </div>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import ProgressBar from './ProgressBar.vue'
import ProgressList from './ProgressList'
import ConfirmationModal from '@/components/ConfirmationModal'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { formatDate } from '@/helpers'
import { useTemplateRef } from 'vue'

const props = defineProps({
  dataset: {
    type: Object,
    required: true
  }
})

const confirmationModalRef = useTemplateRef('confirmationModalRef')

const emit = defineEmits(['onRemove', 'onSelect'])

async function destroyDataset(dataset) {
  const hasImportedData = props.dataset?.progress?.Imported
  const ok = await confirmationModalRef.value.show({
    title: dataset.description,
    message: hasImportedData
      ? 'This will destroy the dataset that is partially imported, are you sure you want to proceed? Imported data will not be destroyed.'
      : 'This will destroy the dataset. Are you sure you want to proceed?.',
    typeButton: 'delete',
    cancelButton: 'Cancel',
    confirmationWord: hasImportedData ? 'DESTROY' : undefined
  })

  if (ok) {
    emit('onRemove', dataset)
  }
}
</script>

<style scoped>
.import-card {
  min-width: 300px;
  max-width: 300px;
}
</style>
