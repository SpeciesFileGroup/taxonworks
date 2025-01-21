<template>
  <SectionPanel
    :status="status"
    :spinner="loadState.conveyances"
    :title="title"
    :menu="false"
  >
    <table class="full_width table-striped">
      <tbody>
        <ConveyanceRow
          v-for="conveyance in conveyances"
          :key="conveyance.id"
          :conveyance="conveyance"
        />
      </tbody>
    </table>
  </SectionPanel>
</template>

<script setup>
import SectionPanel from '../shared/sectionPanel.vue'
import ConveyanceRow from './ConveyanceRow.vue'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { useStore } from 'vuex'

const store = useStore()

const conveyances = computed(() => store.getters[GetterNames.GetConveyances])
const loadState = computed(() => store.getters[GetterNames.GetLoadState])
</script>
