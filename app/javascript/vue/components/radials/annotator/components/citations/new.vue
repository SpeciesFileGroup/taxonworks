<template>
  <div>
    <div class="separate-bottom inline">
      <autocomplete
        url="/sources/autocomplete"
        label="label"
        min="2"
        :send-label="autocompleteLabel"
        @getItem="citation.source_id = $event.id"
        placeholder="Select a source"
        param="term"/>
      <input
        type="text"
        class="normal-input inline pages separate-left"
        v-model="citation.pages"
        placeholder="Pages">
    </div>
    <div class="flex-separate separate-bottom">
      <label class="inline middle">
        <input
          v-model="citation.is_original"
          type="checkbox">
        Is original (does not apply to topics)
      </label>
      <default-element
        class="separate-left"
        label="source"
        type="Source"
        @getLabel="autocompleteLabel = $event"
        @getId="citation.source_id = $event"
        section="Sources"
      />
    </div>
    <div class="separate-bottom">
      <button
        class="button button-submit normal-input"
        :disabled="!validateFields"
        @click="sendCitation()"
        type="button">Create
      </button>
    </div>
  </div>
</template>

<script>
  import DefaultElement from 'components/getDefaultPin.vue'
  import Autocomplete from 'components/autocomplete.vue'

  export default {
    components: {
      DefaultElement,
      Autocomplete
    },
    props: {
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
        autocompleteLabel: undefined,
        citation: this.newCitation()
      }
    },
    methods: {
      newCitation() {
        return {
          annotated_global_entity: decodeURIComponent(this.globalId),
          source_id: undefined,
          is_original: false,
          pages: undefined,
          citation_topics_attributes: []
        }
      },
      sendCitation() {
        this.$emit('create', this.citation);
        this.citation = this.newCitation();
      }
    }
  }
</script>