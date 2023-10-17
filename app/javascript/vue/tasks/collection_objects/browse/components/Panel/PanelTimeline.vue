<template>
  <PanelContainer title="Timeline">
    <table>
      <thead>
        <VDraggable
          v-model="header"
          tag="tr"
          :item-key="(value) => value"
        >
          <template #item="{ element }">
            <th>
              {{ element }}
            </th>
          </template>
        </VDraggable>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in timeline.items"
          :key="index"
        >
          <td
            v-for="property in header"
            :key="property"
            v-html="item[property]"
          />
        </tr>
      </tbody>
    </table>
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../../store/getters/getters'

import VDraggable from 'vuedraggable'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const timeline = computed(() => store.getters[GetterNames.GetTimeline])
const header = ref(['date', 'event', 'object', 'derived_from'])
</script>

<style scoped>
table {
  box-shadow: none;
}

tr {
  border-bottom: 1px solid #eaeaea;
}

th {
  border-bottom: 2px solid #eaeaea;
  text-transform: uppercase;
}
</style>
