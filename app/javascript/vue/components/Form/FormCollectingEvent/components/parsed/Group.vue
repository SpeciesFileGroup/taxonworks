<template>
  <div>
    <div class="field">
      <label>Group</label>
      <autocomplete
        url="https://paleobiodb.org/data1.2/strata/auto.json"
        min="3"
        label="name"
        nested="records"
        :send-label="collectingEvent.group"
        @getItem="(e) => {
            collectingEvent.group = e.name
            collectingEvent.isUnsaved = true
          }"
        :headers="EXTERNAL_HEADERS"
        :add-params="{
          limit: 30,
          vocab: 'pbdb',
          rank: 'group'
        }"
        param="name"
      />
    </div>
    <div class="field">
      <label>Formation</label>
      <autocomplete
        url="https://paleobiodb.org/data1.2/strata/auto.json"
        min="3"
        label="name"
        nested="records"
        :send-label="collectingEvent.formation"
        @getItem="(e) => {
            collectingEvent.formation = e.name
            collectingEvent.isUnsaved = true
          }"
        :headers="EXTERNAL_HEADERS"
        :add-params="{
          limit: 30,
          vocab: 'pbdb',
          rank: 'formation'
        }"
        param="name"
      />
    </div>
    <div class="field label-above">
      <label>Member</label>
      <input
        type="text"
        v-model="collectingEvent.member"
        @change="() => { collectingEvent.isUnsaved = true }"
      />
    </div>
    <div class="field label-above">
      <label>Lithology</label>
      <input
        type="text"
        v-model="collectingEvent.lithology"
        @change="() => { collectingEvent.isUnsaved = true }"
      />
    </div>
    <div class="horizontal-left-content ma-fields">
      <div class="separate-right label-above">
        <label>Minimum MA</label>
        <input
          type="text"
          v-model="collectingEvent.min_ma"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
      </div>
      <div class="separate-left label-above">
        <label>Maximum MA</label>
        <input
          type="text"
          v-model="collectingEvent.max_ma"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'

const collectingEvent = defineModel()

const EXTERNAL_HEADERS = {
  Accept: 'application/json',
  'Content-Type': 'application/json'
}
</script>

<style lang="scss" scoped>
.ma-fields {
  input {
    width: 60px;
  }
}
</style>
