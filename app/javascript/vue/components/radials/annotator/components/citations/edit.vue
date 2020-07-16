<template>
  <div class="field">
    <div class="horizontal-left-content">
      <span v-html="editCitation.object_tag"/>
      <soft-validation
        class="margin-small-left"
        :global-id="editCitation.global_id"/>
    </div>
    <div class="flex-separate separate-bottom separate-top field">
      <label class="inline middle">
        <input
          type="text"
          class="normal-input inline pages"
          v-model="editCitation.pages"
          placeholder="Pages">
        <input
          v-model="editCitation.is_original"
          type="checkbox">
        Is original (does not apply to topics)
      </label>
    </div>
    <button
      class="button button-submit normal-input separate-bottom"
      :disabled="!validateFields"
      @click="sendCitation()"
      type="button">Update
    </button>
    <button
      class="button button-default normal-input separate-bottom"
      @click="newCitation()"
      type="button">New
    </button>
  </div>
</template>
<script>

import SoftValidation from 'components/soft_validations/objectValidation.vue'
export default {
  components: {
    SoftValidation
  },
  props: {
    citation: {
      type: Object,
      required: true
    },
    globalId: {
      type: String,
      required: true
    }
  },
  computed: {
    validateFields() {
      return this.citation.source_id
    }
  },
  data() {
    return {
      editCitation: this.citation,
    }
  },
  watch: {
    citation(newVal) {
      this.citation = newVal
    }
  },
  methods: {
    sendCitation() {
      this.$emit('update', this.editCitation)
    },
    newCitation() {
      this.$emit('new', true)
    }
  }
}
</script>
