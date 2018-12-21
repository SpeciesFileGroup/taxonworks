<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="separate-right">
        <label>Minimun</label>
        <input
          type="text"
          v-model="minimum_elevation">
      </div>
      <div class="separate-right separate-left">
        <label>Maximun</label>
        <input
          type="text"
          v-model="maximum_elevation">
      </div>
      <div class="separate-right separate-left">
        <label>Precision</label>
        +/-
        <input
          type="text"
          v-model="elevation_precision">
      </div>
      <div>
        Unit
        <label>
          <input
            type="radio"
            name="elevation">
          Meters
        </label>
        <label>
          <input
            type="radio"
            name="elevation">
          Feets
        </label>
      </div>
    </div>
  </div>
</template>

<script>

  import { GetterNames } from '../../../../store/getters/getters.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'

  export default {
    computed: {
      minimum_elevation: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].minimum_elevation
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventMinimumElevation, value)
        }
      },
      maximum_elevation: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].maximum_elevation
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventMaximumElevation, value)
        }
      },
      elevation_precision: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].elevation_precision
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventElevationPrecision, value)
        }
      }
    }
  }
</script>

<style scoped>
  input {
    max-width: 60px;
  }
</style>