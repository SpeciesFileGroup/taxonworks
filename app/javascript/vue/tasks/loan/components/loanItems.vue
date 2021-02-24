<template>
  <div class="panel loan-box">
    <spinner-component
      v-if="!loan.id"
      :show-legend="false"
      :show-spinner="false"
      :resize="false"
    />
    <div class="header flex-separate middle">
      <h3>Add loan items</h3>
      <expand-component v-model="displayBody" />
    </div>
    <div
      class="body"
      v-if="displayBody"
    >
      <SwitchComponent
        :options="typeList"
        v-model="view"/>

      <component
        :is="componentView"
        :loan="loan"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import CreateObject from './CreateObject'
import CreateTag from './CreateTag'
import CreatePinboard from './CreatePinboard'
import ExpandComponent from './expand.vue'
import SpinnerComponent from 'components/spinner.vue'
import SwitchComponent from 'components/switch'

const typeList = [
  'Object',
  'Tag',
  'Pinboard'
]

export default {
  components: {
    CreateObject,
    CreateTag,
    CreatePinboard,
    ExpandComponent,
    SpinnerComponent,
    SwitchComponent
  },
  computed: {
    loan () {
      return this.$store.getters[GetterNames.GetLoan]
    },
    componentView () {
      return `Create${this.view}`
    }
  },
  data () {
    return {
      maxItemsWarning: 100,
      typeList: typeList,
      displayBody: true,
      view: typeList[0]
    }
  }
}
</script>
<style lang="scss">
  #edit_loan_task {
    .label-flex {
      display: flex;
      align-items: center;
    }
    .switch-radio {
      label {
        width: 100px;
      }
    }
    .tag_list {
      margin-top: 0.5em;
      align-items: center;
      text-align: right;
      display: flex;
      .tag_label {
        width: 130px;
        min-width: 130px;
      }
      .tag_total {
        margin-left: 1em;
        margin-right: 1em;
        text-align: left;
        min-width: 50px;
      }
    }
  }
</style>
