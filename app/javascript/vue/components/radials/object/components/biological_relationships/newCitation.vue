<template>
  <div>
    <fieldset>
      <legend>Citation</legend>
      <div class="separate-bottom align-start">
        <smart-selector
          model="sources"
          target="BiologicalAssociation"
          klass="BiologicalAssociation"
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
      <div class="flex-separate separate-bottom">
        <input
          type="text"
          class="normal-input inline pages"
          v-model="citation.pages"
          @input="setPage"
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
import SmartSelector from 'components/ui/SmartSelector.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import { convertType } from 'helpers/types'

export default {
  components: {
    LockComponent,
    SmartSelector
  },

  props: {
    globalId: {
      type: String,
      required: true
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
      handler (newVal) {
        this.sendCitation()
      },
      deep: true
    },
    lock (newVal) {
      sessionStorage.setItem('radialObject::source::lock', newVal)
      this.$emit('lock', newVal)
    }
  },

  mounted () {
    this.lock = convertType(sessionStorage.getItem('radialObject::source::lock'))
    if (this.lock) {
      this.citation.source_id = convertType(sessionStorage.getItem('radialObject::source::id'))
      this.citation.pages = convertType(sessionStorage.getItem('radialObject::source::pages'))
      this.sourceLabel = convertType(sessionStorage.getItem('radialObject::source::label'))
    }
  },

  methods: {
    newCitation () {
      return {
        annotated_global_entity: decodeURIComponent(this.globalId),
        source_id: undefined,
        is_original: undefined,
        pages: undefined
      }
    },

    sendCitation () {
      if (this.validateFields) {
        this.$emit('create', this.citation)
      }
    },

    cleanCitation () {
      this.sourceLabel = undefined
      this.citation = this.newCitation()
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
