<template>
  <div>
    <h2 class="flex-separate">{{ (collectionObjects.length > 1 ? 'Container details' : 'Object details') }}
      <div>
        <button 
          type="button"
          v-shortkey="[getMacKey(), 'n']"
          @shortkey="newDigitalization"
          class="button normal-input button-submit separate-right"
          @click="saveCollectionObject">Save</button>  
        <button 
          type="button"
          @shortkey="saveAndNew"
          class="button normal-input button-submit separate-right"
          @click="saveAndNew">Save and new</button> 
        <button
          type="button"
          @click="saveAndNew"
          class="button normal-input button-default">Add to container
        </button>      
      </div>
    </h2>
    <table-collection-objects/>
  </div>
</template>

<script>

import TableCollectionObjects from '../collectionObject/tableCollectionObjects'
import BlockLayout from 'components/blockLayout.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    TableCollectionObjects,
    BlockLayout
  },
  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    collectionObjects() {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
  },
  methods: {
      newDigitalization() {
        this.$store.dispatch(ActionNames.NewCollectionObject)
        this.$store.dispatch(ActionNames.NewIdentifier)
        this.$store.commit(MutationNames.NewTaxonDetermination)
        this.$store.commit(MutationNames.SetTaxonDeterminations, [])
      },
      saveCollectionObject() {
        this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
          this.$store.commit(MutationNames.SetTaxonDeterminations, [])
        })
      },
      saveAndNew() {
        this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
          let that = this
          setTimeout(() => {
            that.newDigitalization()
          }, 500)
        })
      },
    getMacKey() {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    },
  }
}
</script>
