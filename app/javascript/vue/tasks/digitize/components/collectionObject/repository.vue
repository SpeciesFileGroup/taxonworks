<template>
  <div>
    <h2>Repository</h2>
    <smart-selector 
      name="repository"
      v-model="view"
      :options="options"/>
    <autocomplete
      url="/repositories/autocomplete"
      label="label_html"
      param="term"
      placeholder="Search"
      @getItem="repository = $event.id"
      min="2"/>
  </div>
</template>

<script>

import Autocomplete from '../../../../components/autocomplete'
import SmartSelector from '../../../../components/switch'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    Autocomplete,
    SmartSelector
  },
  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    repository: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set(value) {
        return this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    }
  },
  data() {
    return {
      view: 'search',
      options: ['quick', 'recent', 'search']
    }
  }
}
</script>

<style>

</style>
