<template>
  <div class="panel basic-information">
    <div class="header flex-separate">
      <h3>Matrix</h3>
    </div>
    <div class="body">
      <div class="flex-separate">
        <div class="field">
          <label>Name</label><br>
          <input
            v-model="matrixName"
            type="text">
        </div>
      </div>
      <button
        v-if="!matrix.id"
        @click="create"
        class="normal-input button button-submit"
        type="button">Create
      </button>
      <button
        v-else
        @click="updateMatrix"
        class="normal-input button button-submit"
        type="button">Update
      </button>
      <div class="separate-top">
        <label class="separate-top">Select:</label>
        <switch-component
          :options="['Column', 'Row']"
          v-model="matrixView"/>
        <switch-component
          :options="['fixed', 'dynamic']"
          v-model="matrixMode"/>
      </div>
    </div>
  </div>
</template>

<script>

import { CreateMatrix } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

import SwitchComponent from './switch.vue'

export default {
  components: {
    SwitchComponent
  },
  computed: {
    matrixName: {
      get () {
        return this.$store.getters[GetterNames.GetMatrix].name
      },
      set (value) {
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
      get () {
        return this.$store.getters[GetterNames.GetMatrixView] === 'column'
      },
      set (value) {
        this.$store.commit(MutationNames.SetMatrixView, (value ? 'column' : 'row'))
      }
    },
    matrixMode: {
      get () {
        return this.$store.getters[GetterNames.GetMatrixMode] === 'fixed'
      },
      set (value) {
        this.$store.commit(MutationNames.SetMatrixMode, (value ? 'fixed' : 'dynamic'))
      }
    },
    validateData () {
      return this.$store.getters[GetterNames.GetMatrix].name &&
            !this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  methods: {
    create () {
      CreateMatrix(this.matrix).then(response => {
        this.matrix = response.body
      })
    },
    updateMatrix () {
      this.$store.dispatch(ActionNames.UpdateMatrix)
    }
  }
}
</script>