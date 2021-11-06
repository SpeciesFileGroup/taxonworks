<template>
  <fieldset class="separate-bottom">
    <legend>Source</legend>
    <div class="separate-bottom">
      <div
        class="horizontal-left-content align-start"
        v-show="!citation.id"
      >
        <smart-selector
          model="sources"
          target="AssertedDistribution"
          klass="AssertedDistribution"
          pin-section="Sources"
          pin-type="Source"
          label="cached"
          @selected="setSource"
        />
        <lock-component
          class="margin-small-left"
          v-model="lock" />
      </div>
      <hr>
      <div class="margin-small-top">
        <span
          v-if="citation.source_id && !citation.id"
          v-html="sourceLabel"
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

import LockComponent from 'components/ui/VLock/index.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import { convertType } from 'helpers/types'

export default {
  components: {
    LockComponent,
    SmartSelector
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
      sourceLabel: undefined,
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
      this.sourceLabel = newVal
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
      this.sourceLabel = convertType(sessionStorage.getItem('radialObject::source::label'))
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
      this.cleanCitation()
    },

    cleanCitation () {
      this.sourceLabel = undefined
      this.citation = this.newCitation()
      this.sourceLabel = ''
      this.$emit('create', this.citation)
    },

    setCitation (citation) {
      this.citation = citation
    },

    setSource (source) {
      sessionStorage.setItem('radialObject::source::id', source.id)
      sessionStorage.setItem('radialObject::source::label', source.cached)
      this.citation.source_id = source.id
      this.sourceLabel = source.cached
    },

    setPage (value) {
      sessionStorage.setItem('radialObject::source::pages', this.citation.pages)
    }
  }
}
</script>
