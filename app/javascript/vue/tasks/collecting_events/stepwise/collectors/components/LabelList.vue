<template>
  <div>
    <div
      v-if="pagination.stepwise"
      class="flex-separate margin-medium-bottom"
    >
      <VPagination
        :pagination="pagination.stepwise"
        @next-page="loadVerbatimPage($event.page)"
      />
    </div>
    <table class="full_width">
      <thead>
        <tr>
          <th>Count</th>
          <th />
          <th class="full_width">Verbatim Collectors</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in verbatimCollectorFields"
          :class="{ highlight: item.verbatim_collectors === selectedCollectorString }"
          :key="item.verbatim_collectors"
        >
          <td>{{ item.count_collectors }}</td>
          <td>
            <v-btn
              color="primary"
              medium
              :disabled="item.verbatim_collectors === selectedCollectorString"
              @click="setVerbatimCollectorString(item.verbatim_collectors)"
            >
              Pick
            </v-btn>
          </td>
          <td>{{ item.verbatim_collectors }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { watch } from 'vue'
import useStore from '../composables/useStore.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VPagination from '@/components/pagination.vue'

const {
  loadVerbatimPage,
  setVerbatimCollectorString,
  selectedCollectorString,
  verbatimCollectorFields,
  verbatimParams,
  getPages
} = useStore()

watch(verbatimParams, () => loadVerbatimPage(1), { deep: true })

const pagination = getPages()

loadVerbatimPage(1)
</script>
