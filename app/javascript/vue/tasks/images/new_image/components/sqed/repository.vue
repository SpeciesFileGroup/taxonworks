<template>
  <fieldset>
    <legend>Repository</legend>
    <div class="horizontal-left-content">
      <autocomplete
        class="margin-small-right"
        url="/repositories/autocomplete"
        param="term"
        placeholder="Search a repository"
        label="label"
        :clear-after="true"
        @getItem="setRepository"/>
      <default-pin
        class="button-circle margin-small-left"
        type="Repository"
        @getItem="setRepository({ id: $event.id, label: $event.label })"
        section="Repositories"/>
    </div>
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
import DefaultPin from 'components/getDefaultPin.vue'

export default {
  components: {
    Autocomplete,
    DefaultPin
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
