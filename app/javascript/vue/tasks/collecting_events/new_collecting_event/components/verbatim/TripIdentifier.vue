<template>
  <div class="field label-above">
    <label>Trip identifier</label>
    <textarea
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_trip_identifier"/>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
