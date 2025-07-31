<template>
  <block-layout>
    <template #header>
      <h3>Add loan items</h3>
    </template>
    <template #options>
      <VExpand v-model="isExpanded" />
    </template>
    <template #body>
      <template v-if="isExpanded">
        <SwitchComponent
          :options="Object.keys(TYPE_LIST)"
          v-model="currentTab"
        />
        <component
          :is="TYPE_LIST[currentTab]"
          :loan="loan"
        />
      </template>
    </template>
  </block-layout>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import CreateObject from './CreateObject'
import CreateTag from './CreateTag'
import CreatePinboard from './CreatePinboard'
import VExpand from './expand.vue'
import SwitchComponent from '@/components/ui/VSwitch'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const TYPE_LIST = {
  Object: CreateObject,
  Tag: CreateTag,
  Pinboard: CreatePinboard
}

const store = useStore()

const isExpanded = ref(true)
const currentTab = ref('Object')

const loan = computed(() => store.getters[GetterNames.GetLoan])
</script>
<style lang="scss">
#edit_loan_task {
  .label-flex {
    display: flex;
    align-items: center;
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
