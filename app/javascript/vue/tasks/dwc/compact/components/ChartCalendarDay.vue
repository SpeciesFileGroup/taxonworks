<template>
  <div class="dwc-compact-chart panel content">
    <h3>Individuals by calendar day (spherical)</h3>
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

const MONTH_LABELS = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
]

function dayOfYear(dateString) {
  if (!dateString) return null

  const datePart = dateString.includes('/') ? dateString.split('/')[0] : dateString
  const match = datePart.match(/^(\d{4})-(\d{2})-(\d{2})/)

  if (!match) return null

  const date = new Date(parseInt(match[1]), parseInt(match[2]) - 1, parseInt(match[3]))
  const start = new Date(date.getFullYear(), 0, 0)
  const diff = date - start
  const oneDay = 1000 * 60 * 60 * 24

  return Math.floor(diff / oneDay)
}

function aggregate() {
  const dayCounts = new Array(366).fill(0)

  props.rows.forEach((row) => {
    const doy = dayOfYear(row.eventDate)
    const count = parseInt(row.individualCount) || 0

    if (doy && doy >= 1 && doy <= 365) {
      dayCounts[doy] += count
    }
  })

  return dayCounts
}

function renderChart() {
  if (!chartRef.value || !window.echarts) return

  if (!chart) {
    chart = window.echarts.init(chartRef.value)
  }

  const dayCounts = aggregate()
  const maxValue = Math.max(...dayCounts.filter(Boolean), 1)

  const data = []
  for (let day = 1; day <= 365; day++) {
    if (dayCounts[day] > 0) {
      const angle = ((day - 1) / 365) * 360
      data.push([dayCounts[day], angle])
    }
  }

  const monthIndicators = MONTH_LABELS.map((label, i) => {
    const startDay = new Date(2024, i, 1)
    const startOfYear = new Date(2024, 0, 0)
    const doy = Math.floor((startDay - startOfYear) / (1000 * 60 * 60 * 24))
    return { name: label, value: (doy / 365) * 360 }
  })

  chart.setOption({
    tooltip: {
      trigger: 'item',
      formatter(params) {
        const angle = params.value[1]
        const day = Math.round((angle / 360) * 365) + 1
        return `Day ${day}: ${params.value[0]} individuals`
      }
    },
    polar: {},
    angleAxis: {
      type: 'value',
      min: 0,
      max: 360,
      startAngle: 90,
      clockwise: true,
      axisLabel: {
        formatter(value) {
          const match = monthIndicators.find(
            (m) => Math.abs(m.value - value) < 16
          )
          return match ? match.name : ''
        }
      },
      splitNumber: 12
    },
    radiusAxis: {
      min: 0,
      max: maxValue,
      axisLabel: { show: false },
      splitLine: { show: true, lineStyle: { type: 'dashed' } }
    },
    series: [
      {
        type: 'scatter',
        coordinateSystem: 'polar',
        data,
        symbolSize(val) {
          return Math.max(4, Math.min(15, (val[0] / maxValue) * 15))
        }
      }
    ]
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
  height: 400px;
}
</style>
