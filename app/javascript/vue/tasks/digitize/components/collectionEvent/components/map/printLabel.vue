<template>
  <div>
    <div class="flex-separate">
      <button
        class="button normal-input button-default">
        Generate
      </button>
      <span>Que
        <input type="number"/>
      </span>
    </div>
    <label>Print label</label>
    <textarea v-model="printLabel"/>
    <label>Document label</label>
    <textarea v-model="documentLabel"/>
  </div>
</template>

<script>
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  computed: {
    printLabel: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].print_label
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventPrintLabel, value)
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
  }
}
</script>
