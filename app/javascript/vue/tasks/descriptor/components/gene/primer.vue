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
      <template #search>
        <sequence-picker
          clear-after
          @getItem="sendSelected($event.id)"/>
      </template>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SequencePicker from 'components/sequence/sequence_picker/sequence_picker.vue'

export default {
  components: {
    SmartSelector,
    SequencePicker
  },

  props: {
    title: {
      type: String,
      required: true
    }
  },

  emits: ['selected'],

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
  :deep(.vue-autocomplete-input) {
    width: 100%;
  }
</style>
