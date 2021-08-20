<template>
  <div>
    <fieldset>
      <legend>Citation</legend>
      <div class="separate-bottom inline">
        <autocomplete
          url="/sources/autocomplete"
          label="label"
          min="2"
          ref="autocomplete"
          @getItem="setCitation"
          placeholder="Select a source"
          param="term"
        />
        <default-element
          class="separate-left"
          label="source"
          type="Source"
          @getItem="setCitation"
          section="Sources"
        />
      </div>
      <div
        v-if="citation.source_id"
        class="horizontal-left-content margin-medium-top"
      >
        <span v-html="citation.label" />
        <span
          class="button circle-button btn-undo button-default"
          @click="cleanCitation"
        />
      </div>
      <div class="flex-separate separate-bottom">
        <input
          type="text"
          class="normal-input inline pages"
          v-model="citation.pages"
          placeholder="Pages"
        >
        <label class="inline middle">
          <input
            v-model="citation.is_original"
            type="checkbox"
          >
          Is original
        </label>
      </div>
    </fieldset>
  </div>
</template>

<script>
import DefaultElement from 'components/getDefaultPin.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'

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

  emits: ['create'],

  computed: {
    validateFields () {
      return this.citation.source_id
    }
  },

  data () {
    return {
      citation: this.newCitation()
    }
  },

  watch: {
    citation: {
      handler () {
        this.sendCitation()
      },
      deep: true
    }
  },

  methods: {
    newCitation () {
      return {
        annotated_global_entity: decodeURIComponent(this.globalId),
        source_id: undefined,
        is_original: false,
        pages: undefined
      }
    },

    sendCitation () {
      if (this.validateFields) {
        this.$emit('create', this.citation)
      }
    },

    cleanCitation () {
      this.citation = this.newCitation()
    },

    setCitation (item) {
      this.citation.label = item.label
      this.citation.source_id = item.id
    }
  }
}
</script>
