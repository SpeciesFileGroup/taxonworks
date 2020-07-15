<template>
  <modal-component
    @close="$emit('close')">
    <h3 slot="header">Select original citation</h3>
    <div slot="body">
      <p>Already exist an original citation. Select one of the following options to proceed:</p>
      <p>
        <span>Current original citation: <b v-html="originalCitation.source.author_year"/></span>
        <br>
        <span>New citation: <b v-html="citation.author_year"/></span>
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
          label: 'Keep previous citation as original, create new one as non original.',
          value: true
        },
        {
          label: 'Make new citation original.',
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
