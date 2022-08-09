<template>
  <div>
    <h3
      v-if="!!collectingEvent"
      class="middle">
      <span v-html="collectingEvent.object_tag"/>
      <button
        type="button"
        class="button circle-button btn-undo button-default"
        @click="setCE({})"/>
    </h3>
    <smart-selector
      v-else
      class="full_width"
      ref="smartSelector"
      model="collecting_events"
      target="CollectionObject"
      klass="CollectionObject"
      pin-section="CollectingEvents"
      pin-type="CollectingEvent"
      @selected="setCE"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'

export default {
  components: { SmartSelector },

  props: {
    collectingEvent: {
      type: Object,
      default: undefined
    }
  },

  emits: ['onSelect'],

  methods: {
    setCE (ce) {
      this.$emit('onSelect', ce)
    }
  }
}
</script>
