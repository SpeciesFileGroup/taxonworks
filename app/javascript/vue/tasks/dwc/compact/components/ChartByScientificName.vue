<template>
  <div class="dwc-compact-chart panel content">
    <h3>Individuals by scientific name</h3>
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
    const name = row.scientificName || '(not specified)'
    const count = parseInt(row.individualCount) || 0
    counts[name] = (counts[name] || 0) + count
  })

  return counts
}

function renderChart() {
  if (!chartRef.value || !window.echarts) return

  if (!chart) {
    chart = window.echarts.init(chartRef.value)
  }

  const counts = aggregate()
  const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1])
  const labels = sorted.map(([name]) => name)
  const values = sorted.map(([, count]) => count)

  const containerHeight = Math.max(300, labels.length * 25)
  chartRef.value.style.height = containerHeight + 'px'
  chart.resize()

  chart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '30%', right: '5%', top: 10, bottom: 30 },
    xAxis: { type: 'value', name: 'individualCount' },
    yAxis: {
      type: 'category',
      data: labels.reverse(),
      axisLabel: { fontSize: 11 }
    },
    series: [{ type: 'bar', data: values.reverse() }]
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
  min-height: 300px;
}
</style>
