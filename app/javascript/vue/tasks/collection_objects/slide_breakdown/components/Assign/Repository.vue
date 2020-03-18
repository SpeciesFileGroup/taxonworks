<template>
  <fieldset>
    <legend>Repository</legend>
    <autocomplete
      url="/repositories/autocomplete"
      param="term"
      placeholder="Search a repository"
      label="label"
      :clear-after="true"
      @getItem="setRepository"/>
    <p 
      v-if="label"
      class="horizontal-left-content middle">
      <span v-html="label"/>
      <span
        class="circle-button btn-undo button-default"
        @click="removeRepository"/>
    </p>
  </fieldset>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set(newVal) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },
  data () {
    return {
      label: undefined
    }
  },
  methods: {
    setRepository(repository) {
      this.label = repository.label
      this.collectionObject.repository_id = repository.id
    },
    removeRepository () {
      this.label = undefined
      this.collectionObject.repository_id = undefined
    }
  }
}
</script>
