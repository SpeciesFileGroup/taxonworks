<template>
  <div>
    <label>Print label</label>
    <div class="flex-separate separate-bottom middle">
      <div>
        <button
          disabled="true"
          class="button normal-input button-default margin-small-right">
          Generate
        </button>
        <button 
          @click="copyLabel"
          class="button normal-input button-default"
          type="button"
          :disabled="!verbatimLabel">
          Copy verbatim label
        </button>
      </div>
      <label>Que to print
        <input
          class="que-input"
          :disabled="!(printLabel && printLabel.length)"
          size="5"
          v-model="que"
          type="number">
      </label>
      <a 
        v-if="label.id && que > 0"
        target="blank"
        href="/tasks/labels/print_labels">Preview
      </a>
    </div>
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

export default {
  computed: {
    label() {
      return this.$store.getters[GetterNames.GetLabel]
    },
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
    },
    verbatimLabel() {
      return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_label
    }
  },
  methods: {
    copyLabel() {
      this.printLabel = this.verbatimLabel
    }
  }
}
</script>
<style scoped>
  textarea {
    width: 100%;
  }
  .que-input {
    width: 50px;
  }
</style>
