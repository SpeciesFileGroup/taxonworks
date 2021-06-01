<template>
  <div class="vue-otu-picker">
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
    <div class="flex-wrap-column create-otu-panel">
      <match-taxon-name
        v-if="!found"
        class="panel content match-otu-box"
        @createNew="create = true"
        :otu-name="otu.name"
        @selected="createWith"/>
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
  </div>
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import MatchTaxonName from './matchTaxonNames'
import AjaxCall from 'helpers/ajaxCall'

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
      AjaxCall('post', '/otus', { otu: this.otu }).then(response => {
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
    },
    createWith (data) {
      this.taxon = data.taxon
      this.otu.name = data.otuName
      this.createOtu()
    }
  }
}
</script>
<style lang="scss">
.vue-otu-picker {
  position: relative;
  .new-otu-panel {
    position: relative;
    display: none;
    z-index: 50;
  }
  .close-panel {
    opacity: 0.5;
    position: absolute;
    top: 14px;
    right: 14px;
    cursor: pointer;
  }
  .create-otu-panel {
    display: none;
    position: absolute;
    top: 30px;
    z-index: 2001;
  }
  .match-otu-box {
    position: relative;
  }
  &:focus-within, &:hover {
    .create-otu-panel {
      display: flex;
    }
    .new-otu-panel {
      display: flex;
    }
  }
}
</style>
