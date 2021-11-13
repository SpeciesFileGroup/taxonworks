<template>
  <div>
    <h2 class="flex-separate">{{ (collectionObjects.length > 1 ? 'Container details' : 'Object details') }}
      <div>
        <button
          :disabled="!collectionObjects.length"
          type="button"
          @click="addToContainer"
          v-hotkey="shortcuts"
          class="button normal-input button-default">Add to container
        </button>
      </div>
    </h2>
    <table-collection-objects/>
  </div>
</template>

<script>

import TableCollectionObjects from '../collectionObject/tableCollectionObjects'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import platformKey from 'helpers/getPlatformKey.js'

export default {
  components: { TableCollectionObjects },

  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },

    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+p`] = this.addToContainer

      return keys
    }
  },

  methods: {
    newDigitalization () {
      this.$store.dispatch(ActionNames.NewCollectionObject)
      this.$store.dispatch(ActionNames.NewIdentifier)
      this.$store.commit(MutationNames.NewTaxonDetermination)
      this.$store.commit(MutationNames.SetTaxonDeterminations, [])
    },

    addToContainer () {
      if (!this.collectionObjects.length) return
      this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
        this.$store.dispatch(ActionNames.AddToContainer, this.collectionObject).then(() => {
          this.newDigitalization()
          this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
            this.$store.dispatch(ActionNames.AddToContainer, this.collectionObject)
          })
        })
      })
    }
  }
}
</script>
