<template>
  <PanelContainer title="Conveyances">
    <table>
      <tbody>
        <ConveyanceRow
          v-for="conveyance in store.conveyances"
          :key="conveyance.id"
          :conveyance="conveyance"
        />
      </tbody>
    </table>
  </PanelContainer>
</template>

<script setup>
import useStore from '../../store/conveyance.js'
import PanelContainer from './PanelContainer.vue'
import ConveyanceRow from '@/tasks/otu/browse/components/Conveyance/ConveyanceRow.vue'

const store = useStore()
</script>
