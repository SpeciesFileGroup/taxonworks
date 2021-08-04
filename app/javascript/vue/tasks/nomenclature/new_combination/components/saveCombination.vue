<template>
  <button
    type="button"
    ref="saveButton"
    class="button normal-input button-submit create-new-combination"
    v-hotkey="shortcuts"
    :disabled="!validateCreate()"
    @click="save()">
    {{ (newCombination.hasOwnProperty('id') ? 'Update' : 'Create') }}
  </button>
</template>
<script>

import { Combination } from 'routes/endpoints'
import platformKey from 'helpers/getMacKey'

export default {
  props: {
    newCombination: {
      type: Object,
      required: true
    }
  },

  emits: [
    'processing',
    'save',
    'success'
  ],

  computed: {
    shortcuts () {
      const keys = {}
      keys[`${platformKey()}+s`] = this.save

      return keys
    }
  },

  methods: {

    validateCreate () {
      return this.newCombination.protonyms.genus
    },

    setFocus () {
      if (this.validateCreate()) {
        this.$refs.saveButton.focus()
      }
    },

    save () {
      if (this.validateCreate()) {
        (this.newCombination.hasOwnProperty('id') ? this.update(this.newCombination.id) : this.create())
      }
    },

    createRecordCombination () {
      const keys = Object.keys(this.newCombination.protonyms)
      const combination = {
        verbatim_name: this.newCombination.verbatim_name,
        origin_citation_attributes: this.newCombination?.origin_citation_attributes
      }

      keys.forEach((rank) => {
        if (this.newCombination.protonyms[rank]) {
          combination[`${rank}_id`] = this.newCombination.protonyms[rank].id
        }
      })

      return combination
    },
    create () {
      this.$emit('processing', true)
      Combination.create({ combination: this.createRecordCombination() }).then(response => {
        this.$emit('save', response.body)
        this.$emit('processing', false)
        this.$emit('success', true)
        TW.workbench.alert.create('New combination was successfully created.', 'notice')
      }, (response) => {
        this.$emit('processing', false)
        TW.workbench.alert.create(`Something went wrong: ${JSON.stringify(response.body)}`, 'error')
      })
    },
    update (id) {
      this.$emit('processing', true)
      Combination.update(id, { combination: this.createRecordCombination() }).then((response) => {
        this.$emit('save', response.body)
        this.$emit('processing', false)
        this.$emit('success', true)
        TW.workbench.alert.create('New combination was successfully updated.', 'notice')
      })
    }
  }
}
</script>
