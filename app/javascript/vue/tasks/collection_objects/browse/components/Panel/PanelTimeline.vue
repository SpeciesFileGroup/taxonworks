<template>
  <PanelContainer title="Timeline">
    <table>
      <thead>
        <tr>
          <th
            v-for="item in HEADER"
            :key="item"
          >
            {{ item }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in timeline.items"
          :key="index"
        >
          <td
            v-for="property in HEADER"
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
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const timeline = computed(() => store.getters[GetterNames.GetTimeline])

const HEADER = ['type', 'event', 'object', 'derived_from', 'object']
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
