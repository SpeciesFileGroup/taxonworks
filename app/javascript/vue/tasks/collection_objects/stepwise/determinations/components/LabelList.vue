<template>
  <div>
    <div
      v-if="pagination.stepwise"
      class="flex-separate margin-medium-bottom"
    >
      <VPagination
        :pagination="pagination.stepwise"
        @next-page="loadBufferedPage($event.page)"
      />
    </div>
    <table class="full_width">
      <thead>
        <tr>
          <th />
          <th class="full_width">
            Label
          </th>
          <th>Count</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in labels"
          :class="{ highlight: item.buffered_determinations == selectedLabel }"
          :key="item.buffered_determinations"
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
  </div>
</template>

<script setup>
import { watch } from 'vue'
import useStore from '../composables/useStore.js'
import VBtn from 'components/ui/VBtn/index.vue'
import VPagination from 'components/pagination.vue'

const {
  loadBufferedPage,
  setLabel,
  selectedLabel,
  labels,
  bufferedParams,
  getPages
} = useStore()

watch(
  bufferedParams,
  () => loadBufferedPage(1),
  { deep: true }
)

const pagination = getPages()

loadBufferedPage(1)
</script>
