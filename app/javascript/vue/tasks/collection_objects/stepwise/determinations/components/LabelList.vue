<template>
  <table class="full_width">
    <thead>
      <tr>
      <th />
      <th class="full_width">Label</th>
      <th>Count</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in labels"
        :class="{ highlight: item.buffered_determinations == selectedLabel }"
      >
        <td>
          <v-btn
            color="primary"
            medium
            :disabled="item.buffered_determinations == selectedLabel"
            @click="setLabel(item.buffered_determinations)"
          >
            Set
          </v-btn>
        </td>
        <td>{{ item.buffered_determinations }}</td>
        <td>{{ item.count_buffered }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>

import useStore from '../composables/useStore.js'
import VBtn from 'components/ui/VBtn/index.vue'

const {
  loadBufferedPage,
  setLabel,
  selectedLabel,
  labels,
} = useStore()

loadBufferedPage(1)

</script>