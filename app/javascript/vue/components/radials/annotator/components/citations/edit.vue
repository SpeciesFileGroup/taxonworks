<template>
  <div class="field">
    <div class="horizontal-left-content">
      <span v-html="editCitation.object_tag"/>
    </div>
    <div class="flex-separate">
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
    <soft-validation
      :in-place="true"
      :global-id="editCitation.global_id"/>
    <div class="margin-small-top">
      <button
        class="button button-submit normal-input margin-small-right"
        :disabled="!validateFields"
        @click="sendCitation()"
        type="button">Update
      </button>
      <button
        class="button button-default normal-input"
        @click="newCitation()"
        type="button">New
      </button>
    </div>
  </div>
</template>
<script>

import SoftValidation from 'components/soft_validations/objectValidation.vue'
export default {
  components: { SoftValidation },

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

  emits: [
    'update',
    'new'
  ],

  computed: {
    validateFields () {
      return this.citation.source_id
    }
  },

  data () {
    return {
      editCitation: this.citation
    }
  },

  methods: {
    sendCitation () {
      this.$emit('update', this.editCitation)
    },
    newCitation () {
      this.$emit('new', true)
    }
  }
}
</script>
