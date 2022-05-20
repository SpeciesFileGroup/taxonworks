<template>
<div>
  <div
    v-if="pagination"
    class="flex-separate margin-medium-bottom"
  >
    <VPagination 
      :pagination="pagination"
      @next-page="loadPage($event.page)"
    />
  </div>
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
</div>
</template>

<script setup>
import { ref } from 'vue'
import useStore from '../composables/useStore.js'
import VBtn from 'components/ui/VBtn/index.vue'
import getPagination from 'helpers/getPagination.js'
import VPagination from 'components/pagination.vue'

const {
  loadBufferedPage,
  setLabel,
  selectedLabel,
  labels,
} = useStore()

const pagination = ref({})

const loadPage = async page => {
  pagination.value = getPagination(await loadBufferedPage(page))
}

loadPage(1)
</script>