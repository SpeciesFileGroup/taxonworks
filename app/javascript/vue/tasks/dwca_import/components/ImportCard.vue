<template>
  <div
    class="panel content margin-medium-right margin-medium-bottom cursor-pointer import-card"
    @click="$emit('onSelect', dataset.id)">
    <h2 class="flex-separate middle">
      <b>{{ dataset.description }}</b>
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

  methods: {
    async destroyDataset (dataset) {
      const ok = await this.$refs.confirmationModal.show({
        title: dataset.description,
        message: 'This will destroy the dataset. Are you sure you want to proceed?.',
        typeButton: 'delete',
        confirmationWord: this.dataset?.progress?.imported ? 'DESTROY' : undefined
      })
      if (ok) {
        this.$emit('onRemove', dataset)
      }
    }
  }
}
</script>
