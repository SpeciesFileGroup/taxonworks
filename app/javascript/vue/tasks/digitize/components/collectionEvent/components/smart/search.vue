<template>
  <div>
    <autocomplete
      url="/collecting_events/autocomplete"
      min="2"
      label="label"
      @getItem="getCollectingEvent($event.id)"
      placeholder="Search..."
      param="term"/>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete.vue'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import { ActionNames } from '../../../../store/actions/actions.js'
import { GetCollectionEvent } from '../../../../request/resources.js'
import makeCollectingEvent from '../../../../const/collectingEvent.js'

export default {
  components: {
    Autocomplete
  },
  methods: {
    getCollectingEvent(id) {
      GetCollectionEvent(id).then(response => {
        this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response))
        this.$store.dispatch(ActionNames.GetLabels, id)
      })
    }
  }
}
</script>

<style>

</style>
