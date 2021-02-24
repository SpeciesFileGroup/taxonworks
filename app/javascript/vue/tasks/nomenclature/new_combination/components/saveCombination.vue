<template>
  <button
    type="button"
    ref="saveButton"
    :disabled="!validateCreate()"
    v-shortkey="[getMacKey(), 's']"
    @shortkey="save()"
    class="button normal-input button-submit create-new-combination"
    @click="save()">
    {{ (newCombination.hasOwnProperty('id') ? 'Update' : 'Create') }}
  </button>
</template>
<script>

import { CreateCombination, UpdateCombination } from '../request/resources'

export default {
  props: {
    newCombination: {
      type: Object,
      required: true
    }
  },
  methods: {
    validateCreate () {
      return (this.newCombination.protonyms.genus && this.newCombination.protonyms.species)
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    },
    setFocus: function () {
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
      let keys = Object.keys(this.newCombination.protonyms)
      let combination = {}

      combination['verbatim_name'] = this.newCombination.verbatim_name

      if (this.newCombination.hasOwnProperty('origin_citation_attributes')) {
        combination['origin_citation_attributes'] = this.newCombination.origin_citation_attributes
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
      CreateCombination({ combination: this.createRecordCombination() }).then(response => {
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
      UpdateCombination(id, { combination: this.createRecordCombination() }).then((response) => {
        this.$emit('save', response.body)
        this.$emit('processing', false)
        this.$emit('success', true)
        TW.workbench.alert.create('New combination was successfully updated.', 'notice')
      })
    }
  }
}
</script>
