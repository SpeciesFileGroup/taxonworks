<template>
  <div>
    <div class="field">
      <label>Name</label>
      <input 
        v-model="matrixName"
        type="text"/>
    </div>
    <button
      @click="create"
      type="button">Create</button>
  </div>
</template>

<script>

import { CreateMatrix } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

export default {
  computed: {
    matrixName: {
      get() {
        return this.$store.getters[GetterNames.matrixName]
        //vuex getter
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatrixName)
        //vuex mutation
      }
    },
    validateData() {
      return this.$store.getters[GetterNames.GetMatrix].name &&
            !this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  methods: {
    create() {
      CreateMatrix().then(response => {
        this.$store.commit(MutationNames.SetMatrix, response)
      }); 
    }
  }
}
</script>