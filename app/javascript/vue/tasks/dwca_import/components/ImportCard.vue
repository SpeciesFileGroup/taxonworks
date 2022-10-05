<template>
  <div
    class="panel content margin-medium-right margin-medium-bottom cursor-pointer import-card"
    @click="$emit('onSelect', dataset.id)">
    <h2 class="flex-separate middle">
      <b
        class="text-ellipsis"
        :title="dataset.description"
      >
        {{ dataset.description }}
      </b>
      <ul class="context-menu">
        <li>
          <a
            @click.stop=""
            :href="dataset.source_file">Download original</a>
        </li>
        <li>
          <button
            @click.stop="destroyDataset(dataset)"
            class="button button-circle btn-delete"
          />
        </li>
      </ul>
    </h2>
    <span>DwC-A {{ dataset.type.split('::').pop() }}</span>
    <span>Status: <b>{{ dataset.status }}</b></span>
    <hr class="line full_width">
    <progress-bar
      class="full_width"
      :progress="dataset.progress"/>
    <progress-list
      table-mode
      :progress="dataset.progress"/>
    <confirmation-modal ref="confirmationModal"/>
  </div>
</template>

<script>

import ProgressBar from './ProgressBar.vue'
import ProgressList from './ProgressList'
import ConfirmationModal from 'components/ConfirmationModal'

export default {
  components: {
    ProgressBar,
    ProgressList,
    ConfirmationModal
  },

  props: {
    dataset: {
      type: Object,
      required: true
    }
  },

  emits: [
    'onRemove',
    'onSelect'
  ],

  methods: {
    async destroyDataset (dataset) {
      const hasImportedData = this.dataset?.progress?.Imported
      const ok = await this.$refs.confirmationModal.show({
        title: dataset.description,
        message: hasImportedData
          ? 'This will destroy the dataset that is partially imported, are you sure you want to proceed? Imported data will not be destroyed.'
          : 'This will destroy the dataset. Are you sure you want to proceed?.',
        typeButton: 'delete',
        cancelButton: 'Cancel',
        confirmationWord: hasImportedData ? 'DESTROY' : undefined
      })

      if (ok) {
        this.$emit('onRemove', dataset)
      }
    }
  }
}
</script>
