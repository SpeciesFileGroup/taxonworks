<template>
  <div class="vue-otu-picker">
    <div class="horizontal-left-content">
      <autocomplete
        url="/otus/autocomplete"
        class="separate-right"
        label="label"
        min="2"
        @getItem="emitOtu"
        @getInput="callbackInput"
        @found="found = $event"
        placeholder="Select a OTU"
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
      <div class="field">
        <label>Name</label>
        <br>
        <input
          type="text"
          v-model="otu.name">
      </div>
      <div class="field">
        <label>Taxon name</label>
        <br>
        <autocomplete
          url="/taxon_names/autocomplete"
          :autofocus="true"
          label="label"
          min="2"
          @getItem="otu.taxon_name_id = $event.id"
          placeholder="Select a taxon name"
          param="term"/>
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

export default {
  components: {
    Autocomplete
  },
  computed: {
    validateFields() {
      return this.otu.name
    }
  },
  data() {
    return {
      found: true,
      create: false,
      type: undefined,
      otu: {
        name: undefined,
        taxon_name_id: undefined
      }
    }
  },
  watch: {
    type(newVal, oldVal) {
      if(newVal != oldVal) {
        this.resetPicker()
        this.otu.name = newVal
        this.found = true
        this.$emit('getInput', newVal)
      }
    }
  },
  methods: {
    resetPicker() {
      this.otu.name = undefined,
      this.otu.taxon_name_id = undefined,
      this.create = false
    },
    createOtu() {
      this.$http.post('/otus', { otu : this.otu }).then(response => {
        this.emitOtu(response.body)
      })
    },
    emitOtu(otu) {
      this.$emit('getItem', otu)
    },
    callbackInput(event) {
      this.type = event
      this.$emit('getInput', event)
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