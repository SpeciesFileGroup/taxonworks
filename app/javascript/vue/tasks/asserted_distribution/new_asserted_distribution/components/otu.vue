<template>
  <fieldset>
    <legend>Otu</legend>
    <smart-selector
      model="otus"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      ref="smartSelector"
      pin-section="Otus"
      pin-type="Otu"
      :search="true"
      :autocomplete="false"
      :otu-picker="true"
      @selected="sendItem"/>
    <template v-if="selected">
      <p class="horizontal-left-content">
        <span data-icon="ok"/>
        <span v-html="selected"/>
        <span
          class="button circle-button btn-undo button-default"
          @click="unset"/>
      </p>
    </template>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import OtuPicker from 'components/otu/otu_picker/otu_picker'

export default {
  components: {
    SmartSelector,
    OtuPicker
  },
  props: {
    value: {}
  },
  data () {
    return {
      otu: undefined,
      selected: undefined
    }
  },
  watch: {
    value (newVal) {
      if (newVal == undefined)
        this.selected = undefined
    }
  },
  methods: {
    sendItem (item) {
      this.setSelected(item)
      this.$emit('input', item.id)
    },
    setSelected (item) {
      this.selected = item.hasOwnProperty('label') ? item.label : item.object_tag
    },
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.$emit('input', undefined)
      this.selected = undefined
    }
  }
}
</script>

<style scoped>
  li {
    margin-bottom: 8px;
  }
</style>