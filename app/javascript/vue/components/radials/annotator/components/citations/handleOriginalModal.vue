<template>
  <modal-component
    @close="$emit('close')">
    <template #header>
      <h3>Select original citation</h3>
    </template>
    <template #body>
      <p>A new citation is marked as original, but another original citation already exists. Select one of the following actions to proceed:</p>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="true"
              v-model="keepOriginal"
            >
            <span>Keep <b v-html="originalSource.cached" /> as original, save <b v-html="currentSource.cached" /> as non original.</span>
          </label>
        </li>
        <li>
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="false"
              v-model="keepOriginal"
            >
            <span>Save <b v-html="currentSource.cached" /> as original citation.</span>
          </label>
        </li>
      </ul>
    </template>
    <template #footer>
      <button
        type="button"
        class="button normal-input button-submit"
        @click="handleCitation"
      >
        Save
      </button>
    </template>
  </modal-component>
</template>

<script>
import { Citation, Source } from 'routes/endpoints'
import ModalComponent from 'components/ui/Modal'
import CRUD from '../../request/crud.js'

export default {
  mixins: [CRUD],

  components: { ModalComponent },

  props: {
    citation: {
      type: Object,
      required: true
    },

    originalCitation: {
      type: Object,
      required: true
    }
  },

  emits: [
    'create',
    'close'
  ],

  data () {
    return {
      currentSource: {},
      originalSource: {},
      keepOriginal: true
    }
  },

  async created () {
    this.currentSource = (await Source.find(this.citation.source_id)).body
    this.originalSource = (await Source.find(this.originalCitation.source_id)).body
  },

  methods: {
    createNonOriginal () {
      const payload = { ...this.citation, is_original: false }

      Citation.create({ citation: payload }).then(response => {
        this.$emit('create', response.body)
        this.$emit('close')
      })
    },

    changeOriginal () {
      const payload = { ...this.originalCitation, is_original: false }

      Citation.update(this.originalCitation.id, { citation: payload }).then(_ => {
        Citation.create({ citation: this.citation }).then(response => {
          this.$emit('create', response.body)
          this.$emit('close')
        })
      })
    },

    handleCitation () {
      if (this.keepOriginal) {
        this.createNonOriginal()
      } else {
        this.changeOriginal()
      }
    }
  }
}
</script>
