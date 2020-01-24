<template>
  <fieldset>
    <legend>Collecting Event</legend>
    <smart-selector
      model="collecting_events"
      klass="CollectingEvent"
      pin-section="CollectingEvents"
      pin-type="CollectingEvent"
      @selected="setValue"/>
      <p
        v-if="collectingEvent"
        class="middle">
        <span
          class="margin-small-right"
          v-html="label"/>
        <span
          class="button-circle button-default btn-undo"
          @click="removeCE"/>
      </p>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

export default {
  components: {
    SmartSelector
  },
  computed: {
    label () {
      if (!this.collectingEvent) return
      return this.collectingEvent.object_tag
    },
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },
  data () {
    return {
      tabs: [],
      lists: undefined,
      view: undefined,
      collectingEvent: undefined
    }
  },
  methods: {
    setValue(value) {
      this.collectingEvent = value
      this.collectionObject.collecting_event_id = value.id
    },
    removeCE() {
      this.collectingEvent = undefined
      this.collectionObject.collecting_event_id = undefined
    }
  }
}
</script>
