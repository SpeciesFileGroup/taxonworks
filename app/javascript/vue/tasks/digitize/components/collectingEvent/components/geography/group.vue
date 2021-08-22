<template>
  <div>
    <div>
      <div class="field">
        <label>Group</label>
        <autocomplete
          url="https://paleobiodb.org/data1.2/strata/auto.json"
          min="3"
          label="name"
          nested="records"
          @getItem="collectingEvent.group = $event"
          :headers="externalHeaders"
          :add-params="{
            limit: 30,
            vocab: 'pbdb',
            rank: 'group'
          }"
          param="name"/>
      </div>
      <div class="field">
        <label>Formation</label>
        <autocomplete
          url="https://paleobiodb.org/data1.2/strata/auto.json"
          min="3"
          label="name"
          nested="records"
          @getItem="collectingEvent.formation = $event"
          :headers="externalHeaders"
          :add-params="{
            limit: 30,
            vocab: 'pbdb',
            rank: 'formation'
          }"
          param="name"/>
      </div>
      <div class="field">
        <label>Member</label>
        <input
          type="text"
          v-model="collectingEvent.member"
        >
      </div>
      <div class="field">
        <label>Lithology</label>
        <input
          type="text"
          v-model="collectingEvent.lithology"
        >
      </div>
    </div>
    <div class="horizontal-left-content ma-fields">
      <div class="separate-right">
        <label>Minumum MA</label>
        <input
          type="text"
          v-model="collectingEvent.min_ma">
      </div>
      <div class="separate-left">
        <label>Maximum MA</label>
        <input
          type="text"
          v-model="collectingEvent.max_ma">
      </div>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: { Autocomplete },

  data() {
    return {
      externalHeaders: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  .ma-fields {
    input {
      width: 60px;
    }
  }
</style>
