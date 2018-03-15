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
    <div class="middle">
      <label class="switch middle">
        <div class="flex-separate middle space-between-switch-options">
          <span>Column</span>
          <span>Rows</span>
        </div>
        <input type="checkbox"/>
        <div class="slider"></div>
      </label>
    </div>
    <div class="middle">
      <label class="switch middle">
        <div class="flex-separate middle space-between-switch-options">
          <span>Fixed</span>
          <span>Dynamic</span>
        </div>
        <input type="checkbox"/>
        <div class="slider"></div>
      </label>
    </div>
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
  methods: {
    create() {
      CreateMatrix(this.matrix).then(response => {
        this.matrix = response
      }); 
    }
  }
}
</script>
<style scoped>

    .space-between-switch-options {
      padding: 4px;
    }
    .switch input {
      display: none;
    }
    .switch {
      position: relative;
      display: inline-block;
      width: 150px;
      height: 24px;
      justify-content: space-around;
      border-radius: 3px;
      border:1px solid #efefef;
      border-right: 0px;    
      background-color: #efefef;
      box-shadow:inset 0px 1px 4px 0px rgba(0,0,0,0.1); 
    }
    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      -webkit-transition: .4s;
      transition: .4s;
    }

    .slider:before {
      position: absolute;
      content: "";
      height: 24px;
      width: 75px;
      left: 0px;
      bottom: 0px;
      border-radius: 3px;
      border:1px solid #efefef;
      background-color: #FFF;
      transition: .3s;
    }

    input:checked + .slider:before {
      -webkit-transform: translateX(75px);
      -ms-transform: translateX(75px);
      transform: translateX(75px);
    }

</style>