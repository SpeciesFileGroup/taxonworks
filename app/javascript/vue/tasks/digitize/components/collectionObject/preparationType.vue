<template>
  <div>
    <h2>Preparation</h2>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="(itemsGroup, index) in chunkList"
        :key="index"
        class="no_bullets preparation-list">
        <li
          v-for="type in itemsGroup"
          :key="type.id">
          <label>
            <input
              type="radio"
              :value="type.id"
              v-model="collectionObject.preparation_type_id"
              name="collection-object-type">
            {{ type.name }}
          </label>
        </li>
      </ul>
      <lock-component v-model="locked.collection_object.preparation_type_id"/>
    </div>
  </div>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations.js'
import { GetterNames } from '../../store/getters/getters.js'
import { PreparationType } from 'routes/endpoints'
import LockComponent from 'components/ui/VLock/index.vue'
import extendCO from './mixins/extendCO.js'

export default {
  mixins: [extendCO],

  components: { LockComponent },

  data () {
    return {
      coTypes: []
    }
  },

  computed: {
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },

    chunkList () {
      return this.coTypes.chunk(Math.ceil(this.coTypes.length/3))
    }
  },

  created () {
    PreparationType.all().then(response => {
      this.coTypes = response.body
      this.coTypes.unshift({
        id: null,
        name: 'None'
      })
    })
  }
}
</script>

<style scoped>
  .preparation-list {
    width: 100%;
  }
</style>
