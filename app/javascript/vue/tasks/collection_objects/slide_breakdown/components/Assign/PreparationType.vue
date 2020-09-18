<template>
  <fieldset>
    <legend>Preparation</legend>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="itemsGroup in coTypes.chunk(Math.ceil(coTypes.length/2))"
        class="no_bullets full_width">
        <li
          v-for="type in itemsGroup"
          :key="type.id">
          <label>
            <input
              type="radio"
              :checked="type.id == collectionObject.preparation_type_id"
              :value="type.id"
              v-model="collectionObject.preparation_type_id"
              name="collection-object-type">
            {{ type.name }}
          </label>
        </li>
      </ul>
      <lock-component v-model="lock.preparation_type_id"/>
    </div>
  </fieldset>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations.js'
import { GetterNames } from '../../store/getters/getters.js'
import { GetPreparationTypes } from '../../request/resource'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],
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
      coTypes: []
    }
  },
  mounted() {
    GetPreparationTypes().then(response => {
      this.coTypes = response.body
    })
  }
}
</script>
