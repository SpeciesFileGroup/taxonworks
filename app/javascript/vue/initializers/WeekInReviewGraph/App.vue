<template>
  <div class="flexbox flex-wrap-row gap-medium">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <div
      class="panel content item"
      v-for="item in types.data"
      :key="item.target"
    >
      <BarChart
        v-if="item.data.length"
        :data="item"
        :title="item.title"
        :target="item.target"
        :weeks-ago="weeksAgo"
      />
      <div
        v-else
        class="horizontal-center-content middle full_height"
      >
        No data
      </div>
    </div>
  </div>
</template>

<script setup>
import BarChart from './BarChart.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ref, onBeforeMount } from 'vue'
import { ajaxCall } from '@/helpers'

const props = defineProps({
  weeksAgo: {
    type: Number,
    required: true
  }
})

const types = ref([])
const isLoading = ref(false)

onBeforeMount(() => {
  isLoading.value = true
  ajaxCall('get', '/tasks/projects/week_in_review/data', {
    params: {
      weeks_ago: props.weeksAgo
    }
  })
    .then(({ body }) => {
      types.value = body
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
})
</script>
