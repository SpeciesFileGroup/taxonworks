<template>
  <PanelContainer title="Sounds">
    <table>
      <tbody>
        <ConveyanceRow
          v-for="conveyance in conveyances"
          :key="conveyance.id"
          :conveyance="conveyance"
        />
      </tbody>
    </table>
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import ConveyanceRow from '@/tasks/otu/browse/components/Conveyance/ConveyanceRow.vue'

const store = useStore()
const conveyances = computed(() => store.getters[GetterNames.GetConveyances])
</script>
