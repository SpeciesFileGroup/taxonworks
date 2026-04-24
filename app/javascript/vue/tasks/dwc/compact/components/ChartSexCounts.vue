<template>
  <div class="dwc-compact-chart panel content">
    <h3>Individuals by sex</h3>
    <div
      ref="chartRef"
      class="chart-container"
    />
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  }
})

const chartRef = ref(null)
let chart = null

function aggregate() {
  const counts = {}

  props.rows.forEach((row) => {
    const sexValues = (row.sex || '').split('|').map((s) => s.trim()).filter(Boolean)
    const count = parseInt(row.individualCount) || 0

    if (sexValues.length === 0) {
      counts['(not specified)'] = (counts['(not specified)'] || 0) + count
    } else {
      sexValues.forEach((sex) => {
        counts[sex] = (counts[sex] || 0) + count
      })
    }
  })

  return counts
}

function renderChart() {
  if (!chartRef.value || !window.echarts) return

  if (!chart) {
    chart = window.echarts.init(chartRef.value)
  }

  const counts = aggregate()
  const labels = Object.keys(counts).sort()
  const values = labels.map((k) => counts[k])

  chart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: labels, axisLabel: { rotate: 45 } },
    yAxis: { type: 'value', name: 'individualCount' },
    series: [{ type: 'bar', data: values }]
  })
}

onMounted(() => {
  renderChart()
})

watch(() => props.rows, renderChart, { deep: true })

onBeforeUnmount(() => {
  chart?.dispose()
})
</script>

<style scoped>
.chart-container {
  width: 100%;
  height: 300px;
}
</style>
