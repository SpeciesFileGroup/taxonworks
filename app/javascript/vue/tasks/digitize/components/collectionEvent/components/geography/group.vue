<template>
  <div>
    <div>
      <label>Group</label>
      <autocomplete
        url="https://paleobiodb.org/data1.2/strata/auto.json"
        min="3"
        label="name"
        nested="records"
        @getItem="group = $event"
        :headers="externalHeaders"
        :add-params="{
          limit: 30,
          vocab: 'pbdb',
          rank: 'group'
        }"
        param="name"/>
      <label>Formation</label>
      <autocomplete
        url="https://paleobiodb.org/data1.2/strata/auto.json"
        min="3"
        label="name"
        nested="records"
        @getItem="formation = $event"
        :headers="externalHeaders"
        :add-params="{
          limit: 30,
          vocab: 'pbdb',
          rank: 'formation'
        }"
        param="name"/>
      <label>Member</label>
      <input type="text"/>
      <label>Lithology</label>
      <input type="text"/>
    </div>
    <div class="horizontal-left-content ma-fields">
      <div class="separate-right">
        <label>Minumum MA</label>
        <input
          type="text"
          v-model="minMa">
      </div>
      <div class="separate-left">
        <label>Maximum MA</label>
        <input
          type="text"
          v-model="maxMa">
      </div>
    </div>
  </div>
</template>

<script>

  import Autocomplete from 'components/ui/Autocomplete.vue'
  import { GetterNames } from '../../../../store/getters/getters.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'

  export default {
    components: {
      Autocomplete
    },
    computed: {
      maxMa: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].max_ma
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventMaxMa, value)
        }
      },
      minMa: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].min_max
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventMinMa, value)
        }
      },
      formation: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].formation
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventFormation, value)
        }
      },
      group: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].group
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventGroup, value)
        }
      }
    },
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
