<template>
  <fieldset class="separate-bottom">
    <legend>Source</legend>
    <div class="separate-bottom">
      <div class="horizontal-left-content align-start">
        <smart-selector
          model="sources"
          target="AssertedDistribution"
          klass="AssertedDistribution"
          pin-section="Sources"
          pin-type="Source"
          label="cached"
          v-model="selectedSource"
          @selected="setSource"
        />
        <lock-component
          class="margin-small-left"
          v-model="lock"
        />
      </div>
      <hr>
      <div class="margin-small-top">
        <span
          v-if="selectedSource"
          v-html="selectedSource.cached"
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
              :value="citation.is_original"
              type="checkbox"
              @change="setIsOriginal"
            >
            Is original
          </label>
        </li>
        <li v-if="absentField">
          <label class="inline middle">
            <input
              v-model="isAbsent"
              :value="isAbsent"
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
import { Source } from 'routes/endpoints'
import { convertType } from 'helpers/types'

const STORAGE = {
  lock: 'radialObject::source::lock',
  sourceId: 'radialObject::source::id',
  pages: 'radialObject::source::pages',
  isOriginal: 'radialObject::source::isOriginal',
  isAbsent: 'radialObject::assertedDistribution::isAbsent'
}

export default {
  components: {
    LockComponent,
    SmartSelector
  },

  props: {
    absent: {
      type: Boolean,
      default: false
    },

    modelValue: {
      type: Object,
      required: true
    },

    absentField: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'lock',
    'update:absent',
    'update:modelValue'
  ],

  computed: {
    validateFields () {
      return this.citation.source_id
    },

    isAbsent: {
      get () {
        return this.absent
      },

      set (value) {
        this.$emit('update:absent', value)
      }
    },

    citation: {
      get () {
        return this.modelValue
      },

      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    sourceId () {
      return this.citation.source_id
    }
  },

  data () {
    return {
      lock: false,
      selectedSource: undefined
    }
  },

  watch: {
    sourceId: {
      handler (newVal, oldVal) {
        if (newVal) {
          if (newVal !== oldVal) {
            Source.find(newVal).then(({ body }) => {
              this.selectedSource = body
            })
          }
        } else {
          this.selectedSource = undefined
        }
      },
      deep: true
    },

    isAbsent (newVal) {
      sessionStorage.setItem(STORAGE.isAbsent, newVal)
    },

    lock (newVal) {
      sessionStorage.setItem(STORAGE.lock, newVal)
      this.$emit('lock', newVal)
    }
  },

  mounted () {
    const value = convertType(sessionStorage.getItem(STORAGE.lock))

    if (value !== null) {
      this.lock = value === true
    }

    if (this.lock) {
      this.citation.source_id = convertType(sessionStorage.getItem(STORAGE.sourceId))
      this.citation.is_original = convertType(sessionStorage.getItem(STORAGE.isOriginal))
      this.citation.pages = convertType(sessionStorage.getItem(STORAGE.pages))
      this.isAbsent = convertType(sessionStorage.getItem(STORAGE.isAbsent))
    }
  },

  methods: {
    setSource (source) {
      sessionStorage.setItem(STORAGE.sourceId, source.id)
      this.citation.source_id = source.id
    },

    setPage (e) {
      sessionStorage.setItem(STORAGE.pages, e.target.value)
    },

    setIsOriginal (e) {
      sessionStorage.setItem(STORAGE.isOriginal, e.target.value)
    }
  }
}
</script>
