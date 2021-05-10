<template>
  <fieldset>
    <legend>Sequence</legend>
    <smart-selector
      class="margin-medium-bottom"
      model="sequences"
      pin-section="Sequences"
      pin-type="Sequence"
      @selected="sendSelected"
      :add-tabs="['search']"
      :search="false"
    >
      <sequence-picker
        slot="search"
        :clear-after="true"
        @getItem="sendSelected($event.id)"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import SequencePicker from 'components/sequence/sequence_picker/sequence_picker.vue'

export default {
  props: {
    title: {
      type: String,
      required: true
    }
  },
  components: {
    SmartSelector,
    SequencePicker
  },
  data () {
    return {
      lists: [],
      tabs: ['search'],
      view: undefined,
      selected: undefined
    }
  },
  methods: {
    sendSelected (sequence) {
      this.$emit('selected', sequence)
    }
  }
}
</script>
<style scoped>
  ::v-deep .vue-autocomplete-input {
    width: 100%;
  }
</style>