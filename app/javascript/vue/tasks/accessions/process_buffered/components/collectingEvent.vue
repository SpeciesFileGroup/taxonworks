<template>
  <div>
    <div class="field">
      <label>Verbatim locality</label>
      <autocomplete
        url="/collecting_events/autocomplete_collecting_event_verbatim_locality"
        param="term"
        v-model="collectingEvent.verbatim_locality"
        label="label"
        @getItem="collectingEvent.verbatim_locality = $event.value"
      />
    </div>
    <div class="field">
      <label>Geographic area</label>
      <autocomplete
        url="/geographic_areas/autocomplete"
        param="term"
        label="label_html"
        display="label"
        @getItem="collectingEvent.geographic_area_id = $event.id"
      />
    </div>
  </div>
</template>

<script>

import { GetCollectingEvent } from '../request/resource'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    collectionObject: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      collectingEvent: {
        verbatim_locality: undefined,
        geographic_area_id: undefined
      }
    }
  },
  watch: {
    collectionObject: {
      handler(newVal) {
        if (newVal && newVal.collecting_event_id) {
          GetCollectingEvent(newVal.collecting_event_id).then(response => {
            this.collectingEvent = response.body
          })
        }
      },
      immediate: true
    }
  },
  methods: {
  }
}
</script>