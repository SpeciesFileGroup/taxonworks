<template>
  <modal-component
    @close="$emit('close')">
    <h3 slot="header">Select original citation</h3>
    <div slot="body">
      <p>A new citation is marked as original, but another original citation already exists. Select one of the following actions to proceed:</p>
      <p>
        <span>Existing original citation: <b v-html="originalCitation.source.author_year"/></span>
        <br>
        <span>Proposed new original citation: <b v-html="citation.author_year"/></span>
      </p>
      <ul class="no_bullets">
        <li v-for="option in options">
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="option.value"
              v-model="keepOriginal">
            {{ option.label }}
          </label>
        </li>
      </ul>
    </div>
    <div slot="footer">
      <button
        type="button"
        class="button normal-input button-submit"
        @click="handleCitation">
        Save
      </button>
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal'
import CRUD from '../../request/crud.js'

export default {
  mixins: [CRUD],
  components: {
    ModalComponent
  },
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
  data () {
    return {
      options: [
        {
          label: 'Keep the existing citation as original, save a new one as non original.',
          value: true
        },
        {
          label: 'Save a new citation as original.',
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
<style scoped>
  /deep/ .modal-container {
    background-color: white !important;
  }
</style>
