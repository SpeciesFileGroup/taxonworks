<template>
  <div>
    <p>
      <label>
        <input
          type="checkbox"
          v-model="depiction.is_metadata_depiction">
          Is metadata depiction
      </label>
    </p>
  </div>
</template>

<script>
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    depiction: {
      get () {
        return this.$store.getters[GetterNames.GetDepiction]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepiction, value)
      }
    }
  }
}
</script>

<style>

</style>