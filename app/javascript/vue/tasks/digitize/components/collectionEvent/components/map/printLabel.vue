<template>
  <div>
    <div class="flex-separate">
      <button
        @click="createLabel"
        class="button normal-input button-default">
        Generate
      </button>
      <span>Que
        <input
          :disabled="!(printLabel && printLabel.length)"
          v-model="que"
          type="number">
      </span>
    </div>
    <label>Print label</label>
    <textarea
      v-model="printLabel"
      cols="45"
      rows="12"/>
    <label>Document label</label>
    <textarea
      v-model="documentLabel"
      cols="45"
      rows="6"/>
  </div>
</template>

<script>
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import GenerateLabel from '../../../../helpers/createLabel.js'

export default {
  computed: {
    printLabel: {
      get() {
        return this.$store.getters[GetterNames.GetLabel].text
      },
      set(value) {
        this.$store.commit(MutationNames.SetLabelText, value)
      }
    },
    que: {
      get() {
        return this.$store.getters[GetterNames.GetLabel].total
      },
      set(value) {
        this.$store.commit(MutationNames.SetLabelTotal, value)
      }
    },
    documentLabel: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].document_label
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventDocumentLabel, value)
      }
    }
  },
  methods: {
    createLabel() {
      GenerateLabel('test')
    }
  }
}
</script>
