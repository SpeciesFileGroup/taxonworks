<template>
  <div>
    <div class="field">
      <label>Name</label><br>
      <input 
        v-model="matrixName"
        type="text"/>
    </div>
    <button
      v-if="!matrix.id"
      @click="create"
      class="normal-input button button-submit"
      type="button">Create</button>
    <switch-component :options="['Column', 'Row']" v-model="test"/>
    <switch-component :options="['Fixed', 'Dynamic']" v-model="test2"/>
  </div>
</template>

<script>

import { CreateMatrix } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

import SwitchComponent from './switch.vue'

export default {
  components: {
    SwitchComponent
  },
  computed: {
    matrixName: {
      get() {
        return this.$store.getters[GetterNames.matrixName]
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatrixName, value)
      }
    },
    matrix: {
      get() {
        return this.$store.getters[GetterNames.GetMatrix]
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatrix, value)
      }
    },
    validateData() {
      return this.$store.getters[GetterNames.GetMatrix].name &&
            !this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  data() {
    return {
      test: true,
      test2: false
    }
  },
  methods: {
    create() {
      CreateMatrix(this.matrix).then(response => {
        this.matrix = response
      }); 
    }
  }
}
</script>