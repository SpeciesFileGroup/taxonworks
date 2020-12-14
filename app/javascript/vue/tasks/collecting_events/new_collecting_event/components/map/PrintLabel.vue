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
          :disabled="!isEmpty">
          Copy verbatim label
        </button>
      </div>
      <label>Que to print
        <input
          class="que-input"
          :disabled="!(collectingEvent.label.text && collectingEvent.label.text.length)"
          size="5"
          v-model="collectingEvent.label.total"
          type="number">
      </label>
      <a
        v-if="collectingEvent.label.id && collectingEvent.label.total > 0"
        target="blank"
        href="/tasks/labels/print_labels/index">Preview
      </a>
    </div>
    <textarea
      v-model="collectingEvent.label.text"
      cols="45"
      rows="12"/>
    <label>Document label</label>
    <textarea
      v-model="collectingEvent.document_label"
      cols="45"
      rows="6"/>
  </div>
</template>

<script>
import extendCE from '../mixins/extendCE.js'

export default {
  mixins: [extendCE],
  computed: {
    isEmpty () {
      return this.collectingEvent.label.text.length === 0
    }
  },
  methods: {
    copyLabel () {
      this.collectingEvent.label.text = this.collectingEvent.verbatim_label
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
