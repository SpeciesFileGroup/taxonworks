<template>
  <div>
    <fieldset>
      <legend>Citation</legend>
      <div class="separate-bottom inline">
        <autocomplete
          url="/sources/autocomplete"
          label="label"
          min="2"
          :send-label="autocompleteLabel"
          ref="autocomplete"
          @getItem="citation.source_id = $event.id"
          placeholder="Select a source"
          param="term"/>
        <default-element
          class="separate-left"
          label="source"
          type="Source"
          @getLabel="autocompleteLabel = $event"
          @getId="citation.source_id = $event"
          section="Sources"
        />
      </div>
      <div class="flex-separate separate-bottom">
        <input
          type="text"
          class="normal-input inline pages"
          v-model="citation.pages"
          placeholder="Pages">
        <label class="inline middle">
          <input
            v-model="citation.is_original"
            type="checkbox">
          Is original
        </label>
      </div>
    </fieldset>
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
    watch: {
      citation: {
        handler(newVal) {
          this.sendCitation()
        },
        deep: true
      }
    },
    methods: {
      newCitation() {
        return {
          annotated_global_entity: decodeURIComponent(this.globalId),
          source_id: undefined,
          is_original: false,
          pages: undefined,
        }
      },
      sendCitation() {
        if(this.validateFields) {
          this.$emit('create', this.citation);
        }
      },
      cleanCitation() {
        this.autocompleteLabel = ''
        this.$refs.autocomplete.cleanInput()
        this.citation = this.newCitation()
      }
    }
  }
</script>