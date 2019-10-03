<template>
  <fieldset class="separate-bottom">
    <legend>Source</legend>
    <div class="inline separate-bottom">
      <autocomplete
        url="/sources/autocomplete"
        label="label"
        min="2"
        ref="autocomplete"
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
    <div class="flex-separate">
      <input
        class="normal-input inline pages"
        v-model="citation.pages"
        placeholder="pages"
        type="text">
      <label class="inline middle">
        <input
          v-model="citation.is_absent"
          type="checkbox">
        Is absent
      </label>
    </div>
  </fieldset>
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
      display: {
        type: String,
        default: ''
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
      },
      display(newVal) {
        this.autocompleteLabel = newVal
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
      cleanInput() {
        this.$refs.autocomplete.cleanInput()
        this.cleanCitation()
      },
      cleanCitation() {
        this.autocompleteLabel = undefined
        this.citation = this.newCitation()
        this.autocompleteLabel = ''
        this.$emit('create', this.citation);
      }
    }
  }
</script>