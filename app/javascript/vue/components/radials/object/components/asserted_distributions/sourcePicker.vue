<template>
  <fieldset class="separate-bottom">
    <legend>Source</legend>
    <div class="separate-bottom">
      <div
        class="horizontal-left-content"
        v-show="!citation.id"
      >
        <autocomplete
          url="/sources/autocomplete"
          label="label_html"
          min="2"
          ref="autocomplete"
          :clear-after="true"
          @getItem="setSource"
          placeholder="Select a source"
          param="term"
        />
        <template>
          <default-element
            v-if="!citation.source_id"
            class="separate-left"
            label="source"
            type="Source"
            @getItem="setSource"
            section="Sources"
          />
          <span
            v-else
            @click="cleanCitation"
            class="separate-left"
            data-icon="reset"
          />
          <lock-component v-model="lock" />
        </template>
      </div>
      <div class="margin-small-top">
        <span
          v-if="citation.source_id && !citation.id"
          v-html="autocompleteLabel"
        />
      </div>
      <span
        v-if="citation.id"
        class="margin-small-right"
        v-html="citation.citation_source_body"
      />
    </div>
    <div class="horizontal-left-content">
      <input
        class="normal-input inline pages margin-medium-right"
        v-model="citation.pages"
        @input="setPage"
        placeholder="pages"
        type="text"
      >
      <ul class="no_bullets context-menu">
        <li>
          <label class="inline middle">
            <input
              v-model="citation.is_original"
              type="checkbox"
            >
            Is original
          </label>
        </li>
        <li>
          <label class="inline middle">
            <input
              v-model="citation.is_absent"
              type="checkbox"
            >
            Is absent
          </label>
        </li>
      </ul>
    </div>
  </fieldset>
</template>

<script>
import DefaultElement from 'components/getDefaultPin.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import { convertType } from 'helpers/types'

export default {
  components: {
    DefaultElement,
    Autocomplete,
    LockComponent
  },

  props: {
    display: {
      type: String,
      default: ''
    }
  },

  emits: [
    'lock',
    'create'
  ],

  computed: {
    validateFields () {
      return this.citation.source_id
    }
  },

  data () {
    return {
      autocompleteLabel: undefined,
      citation: this.newCitation(),
      lock: false
    }
  },

  watch: {
    citation: {
      handler () {
        this.sendCitation()
      },
      deep: true
    },

    display (newVal) {
      this.autocompleteLabel = newVal
    },

    lock (newVal) {
      sessionStorage.setItem('radialObject::source::lock', newVal)
      this.$emit('lock', newVal)
    }
  },

  mounted () {
    const value = convertType(sessionStorage.getItem('radialObject::source::lock'))
    if (value !== null) {
      this.lock = value === true
    }

    if (this.lock) {
      this.citation.source_id = convertType(sessionStorage.getItem('radialObject::source::id'))
      this.citation.pages = convertType(sessionStorage.getItem('radialObject::source::pages'))
      this.autocompleteLabel = convertType(sessionStorage.getItem('radialObject::source::label'))
    }
  },

  methods: {
    newCitation () {
      return {
        id: undefined,
        source_id: undefined,
        is_absent: false,
        pages: undefined,
        is_original: undefined,
        citation_source_body: undefined
      }
    },

    sendCitation () {
      if (this.validateFields) {
        this.$emit('create', this.citation)
      }
    },

    cleanInput () {
      this.$refs.autocomplete.cleanInput()
      this.cleanCitation()
    },

    cleanCitation () {
      this.autocompleteLabel = undefined
      this.citation = this.newCitation()
      this.autocompleteLabel = ''
      this.$emit('create', this.citation)
    },

    setCitation (citation) {
      this.citation = citation
    },

    setSource (source) {
      sessionStorage.setItem('radialObject::source::id', source.id)
      sessionStorage.setItem('radialObject::source::label', source.label)
      this.citation.source_id = source.id
      this.autocompleteLabel = source.label
    },

    setPage (value) {
      sessionStorage.setItem('radialObject::source::pages', this.citation.pages)
    },

    setFocus () {
      this.$refs.autocomplete.setFocus()
    }
  }
}
</script>
