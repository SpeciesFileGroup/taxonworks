<template>
  <div>
    <p>
      <label>
        <input
          type="checkbox"
          v-model="identifier.is_metadata_depiction">
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
    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifier, value)
      }
    }
  }
}
</script>

<style>

</style>