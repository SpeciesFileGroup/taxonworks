<template>
  <div class="flexbox flex-wrap-row gap-medium">
    <div
      class="panel content item"
      v-for="item in types.data"
      :key="item.target"
    >
      <BarChart
        :data="item"
        :title="item.title"
        :target="item.target"
        :weeks-ago="weeksAgo"
      />
    </div>
  </div>
</template>

<script setup>
import BarChart from './BarChart.vue'
import { ref, onBeforeMount } from 'vue'
import { ajaxCall } from '@/helpers'

const props = defineProps({
  weeksAgo: {
    type: Number,
    required: true
  }
})

const types = ref([])

onBeforeMount(() => {
  ajaxCall('get', '/tasks/projects/week_in_review/data', {
    params: {
      weeks_ago: props.weeksAgo
    }
  })
    .then(({ body }) => {
      types.value = body
    })
    .catch(() => {})
})
</script>
