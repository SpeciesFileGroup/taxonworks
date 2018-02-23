<template>
  <div>
    <h3>Source</h3>
    <div class="separate-bottom inline">
      <autocomplete
        url="/sources/autocomplete"
        label="label"
        min="2"
        :send-label="autocompleteLabel"
        @getItem="citation.source_id = $event.id"
        placeholder="Select a source"
        param="term"/>
      <template>
        <default-element
          v-if="!citation.source_id"
          class="separate-left"
          label="source"
          type="Source"
          @getLabel="autocompleteLabel = $event"
          @getId="citation.source_id = $event"
          section="Sources"
        />
        <span 
          v-else
          @click="cleanCitation"
          class="separate-left"
          data-icon="reset"/>
      </template>
    </div>
    <div class="separate-bottom">
      <label class="inline middle">
        <input
          v-model="citation.is_absent"
          type="checkbox">
        Is absent
      </label>
    </div>
  </div>
</template>

<script>
  import DefaultElement from '../../../getDefaultPin.vue'
  import Autocomplete from '../../../autocomplete.vue'

  export default {
    components: {
      DefaultElement,
      Autocomplete
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
          source_id: undefined,
          is_absent: false,
          pages: undefined,
        }
      },
      sendCitation() {
        if(this.validateFields) {
          this.$emit('create', this.citation);
        }
      },
      cleanCitation() {
        this.autocompleteLabel = undefined
        this.citation = this.newCitation()
        this.$emit('create', this.citation);
      }
    }
  }
</script>