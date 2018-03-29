<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Matrix</h3>
    </div>
    <div class="body">
      <div class="field">
        <label>Name</label><br>
        <input
          v-model="matrixName"
          type="text">
      </div>
      <button
        v-if="!matrix.id"
        @click="create"
        class="normal-input button button-submit"
        type="button">Create</button>
      <switch-component
        :options="['Column', 'Row']"
        v-model="matrixView"/>
      <switch-component
        :options="['Fixed', 'Dynamic']"
        v-model="matrixMode"/>
    </div>
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
        return this.$store.getters[GetterNames.GetMatrix].name
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
    matrixView: {
      get() {
        return (this.$store.getters[GetterNames.GetMatrixView] == 'column' ? true : false)
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatrixView, (value ? 'column' : 'row'))
      }
    },
    matrixMode: {
      get() {
        return (this.$store.getters[GetterNames.GetMatrixMode] == 'fixed' ? true : false)
      },
      set(value) {
        this.$store.commit(MutationNames.SetMatrixMode, (value ? 'fixed' : 'dynamic'))
      }
    },
    validateData() {
      return this.$store.getters[GetterNames.GetMatrix].name &&
            !this.$store.getters[GetterNames.GetMatrix].id
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