<template>
  <div>
    <div>
      <label>Group</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Formation</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Member</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Lithology</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
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

  import Autocomplete from '../../../../../../components/autocomplete.vue'
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
