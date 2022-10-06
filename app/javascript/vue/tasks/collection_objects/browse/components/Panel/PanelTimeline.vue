<template>
  <div class="panel content">
    <h3>Timeline</h3>
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
          >
            {{ item[property] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'

const store = useStore()
const timeline = computed(() => store.getters[GetterNames.GetTimeline])

const HEADER = ['type', 'event', 'object', 'derived_from', 'object']
</script>
