<template>
  <div class="vue-otu-picker">
    <div class="horizontal-left-content">
      <autocomplete
        :input-id="inputId"
        url="/otus/autocomplete"
        class="separate-right"
        label="label_html"
        min="2"
        display="label"
        @getItem="emitOtu"
        @getInput="callbackInput"
        @found="found = $event"
        :clear-after="clearAfter"
        placeholder="Select an OTU"
        param="term"/>
      <button
        v-if="!found"
        class="button normal-input button-default"
        type="button"
        @click="create = true">
        New
      </button>
    </div>
    <div
      v-if="create"
      class="new-otu-panel panel content">
      <span
        class="close-panel small-icon"
        data-icon="close"
        @click="create = false"/>
      <div class="field label-above">
        <label>Name</label>
        <input
          type="text"
          class="full_width"
          v-model="otu.name">
      </div>
      <div class="field label-above">
        <label>Taxon name</label>
        <div
          v-if="taxon"
          class="flex-separate middle">
          <span
            class="margin-small-right"
            v-html="taxonLabel"/>
          <span
            class="button circle-button btn-undo button-default"
            @click="taxon = undefined"/>
        </div>
        <template v-else>
          <autocomplete
            url="/taxon_names/autocomplete"
            :autofocus="true"
            label="label"
            min="2"
            :clear-after="true"
            @getItem="setTaxon"
            placeholder="Select a taxon name"
            param="term"/>
          <match-taxon-name
            class="margin-small-top"
            :otu-name="otu.name"
            @selected="setTaxon"/>
        </template>
      </div>
      <button
        class="button normal-input button-submit"
        :disabled="!validateFields"
        @click="createOtu"
        type="button">Create
      </button>
    </div>
  </div>
</template>
<script>

import Autocomplete from '../../autocomplete.vue'
import MatchTaxonName from './matchTaxonNames'

export default {
  components: {
    Autocomplete,
    MatchTaxonName
  },
  props: {
    inputId: {
      type: String,
      default: undefined
    },
    clearAfter: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    validateFields () {
      return this.otu.name
    },
    taxonLabel () {
      return this.taxon && this.taxon.hasOwnProperty('label_html') ? this.taxon.label_html : this.taxon['object_tag']
    }
  },
  data () {
    return {
      found: true,
      create: false,
      type: undefined,
      taxon: undefined,
      otu: {
        name: undefined,
        taxon_name_id: undefined
      }
    }
  },
  watch: {
    type (newVal, oldVal) {
      if(newVal != oldVal) {
        this.resetPicker()
        this.otu.name = newVal
        this.found = true
        this.$emit('getInput', newVal)
      }
    }
  },
  methods: {
    resetPicker () {
      this.otu.name = undefined
      this.otu.taxon_name_id = undefined
      this.create = false
    },
    createOtu () {
      if (this.taxon) {
        this.otu.taxon_name_id = this.taxon.id
      }
      this.$http.post('/otus', { otu : this.otu }).then(response => {
        this.emitOtu(response.body)
        this.create = false
        this.found = true
      })
    },
    emitOtu(otu) {
      this.$emit('getItem', otu)
    },
    callbackInput(event) {
      this.type = event
      this.$emit('getInput', event)
    },
    setTaxon (taxon) {
      this.taxon = taxon
    }
  }
}
</script>
<style lang="scss">
.vue-otu-picker {
  position: relative;
  .new-otu-panel {
    position: absolute;
    z-index: 50;
  }
  .close-panel {
    opacity: 0.5;
    position: absolute;
    top: 14px;
    right: 14px;
    cursor: pointer;
  }
}
</style>