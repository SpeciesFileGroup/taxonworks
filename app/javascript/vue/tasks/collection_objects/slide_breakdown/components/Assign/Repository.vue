<template>
  <fieldset>
    <legend>Repository</legend>
    <div class="horizontal-left-content align-start">
      <smart-selector
        model="repositories"
        klass="CollectionObject"
        pin-section="Repositories"
        pin-type="Repository"
        @selected="setRepository"/>
      <lock-component
        class="margin-small-left"
        v-model="lock.repository_id"/>
    </div>
    <p
      v-if="repository"
      class="horizontal-left-content middle">
      <span v-html="repository.name"/>
      <span
        class="circle-button btn-undo button-default"
        @click="removeRepository"/>
    </p>
  </fieldset>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { GetRepository } from '../../request/resource'
import SmartSelector from 'components/smartSelector'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],
  components: {
    SmartSelector
  },
  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },
  data () {
    return {
      repository: undefined
    }
  },
  mounted () {
    if (this.collectionObject.repository_id) {
      GetRepository(this.collectionObject.repository_id).then(response => {
        this.setRepository(response.body)
      })
    }
  },
  methods: {
    setRepository (repository) {
      this.repository = repository
      this.collectionObject.repository_id = repository.id
    },
    removeRepository () {
      this.repository_id = undefined
      this.collectionObject.repository_id = undefined
    }
  }
}
</script>
