<template>
  <modal-component
    @close="$emit('close')">
    <template #header>
      <h3>Select original citation</h3>
    </template>
    <template #body>
      <p>A new citation is marked as original, but another original citation already exists. Select one of the following actions to proceed:</p>
      <ul class="no_bullets">
        <li v-for="option in options">
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="option.value"
              v-model="keepOriginal">
            <span v-html="option.label"/>
          </label>
        </li>
      </ul>
    </template>
    <template #footer>
      <button
        type="button"
        class="button normal-input button-submit"
        @click="handleCitation">
        Save
      </button>
    </template>
  </modal-component>
</template>

<script>

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
      options: [
        {
          label: `Keep <b>${this.originalCitation.source.author_year}</b> as original, save <b>${this.citation.author_year}</b> as non original.`,
          value: true
        },
        {
          label: `Save <b>${this.citation.author_year}</b> as original citation.`,
          value: false
        }
      ],
      keepOriginal: true
    }
  },

  methods: {
    createNonOriginal () {
      this.create('/citations.json', { citation: Object.assign({}, this.citation, { is_original: false }) }).then(response => {
        this.$emit('create', response.body)
        this.$emit('close')
      })
    },

    changeOriginal () {
      this.update(`/citations/${this.originalCitation.id}.json`, { citation: Object.assign({}, this.originalCitation, { is_original: false }) }).then(response => {
        this.create('/citations.json', { citation: this.citation }).then(response => {
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
