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
          :send-label="collectingEvent.group"
          :headers="externalHeaders"
          :add-params="{
            limit: 30,
            vocab: 'pbdb',
            rank: 'group'
          }"
          param="name"
          @get-item="
            (item) => {
              collectingEvent.group = item.name
              updateChange()
            }
          "
        />
      </div>
      <div class="field">
        <label>Formation</label>
        <autocomplete
          url="https://paleobiodb.org/data1.2/strata/auto.json"
          min="3"
          label="name"
          :send-label="collectingEvent.formation"
          nested="records"
          :headers="externalHeaders"
          :add-params="{
            limit: 30,
            vocab: 'pbdb',
            rank: 'formation'
          }"
          param="name"
          @get-item="
            (item) => {
              collectingEvent.formation = item.name
              updateChange()
            }
          "
        />
      </div>
      <div class="field">
        <label>Member</label>
        <input
          type="text"
          v-model="collectingEvent.member"
          @change="updateChange"
        />
      </div>
      <div class="field">
        <label>Lithology</label>
        <input
          type="text"
          v-model="collectingEvent.lithology"
          @change="updateChange"
        />
      </div>
    </div>
    <div class="horizontal-left-content ma-fields">
      <div class="separate-right">
        <label>Minumum MA</label>
        <input
          type="text"
          v-model="collectingEvent.min_ma"
          @change="updateChange"
        />
      </div>
      <div class="separate-left">
        <label>Maximum MA</label>
        <input
          type="text"
          v-model="collectingEvent.max_ma"
          @change="updateChange"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: { Autocomplete },

  data() {
    return {
      externalHeaders: {
        Accept: 'application/json',
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
