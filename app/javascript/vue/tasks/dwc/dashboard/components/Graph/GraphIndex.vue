<template>
  <div>
    <h2>DwC occurrence record freshness</h2>
    <vue-chart
      style="max-height: 500px"
      type="bar"
      :data="chartState.data"
      :options="chartState.options"/>
  </div>
</template>
<script setup>

import { reactive, watch, inject } from 'vue'
import { humanize } from 'helpers/strings.js'
import { randomHue } from 'helpers/colors.js'
import VueChart from 'components/ui/Chart/index.vue'

const DATASET_LABELS = [
  { label: 'Never', property: 'never', backgroundColor: randomHue(0) },
  { label: 'One day',property: 'one_day', backgroundColor: randomHue(1) },
  { label: 'One week', property: 'one_week', backgroundColor: randomHue(2) },
  { label: 'One month', property: 'one_month', backgroundColor: randomHue(3) },
  { label: 'One year', property: 'one_year', backgroundColor: randomHue(4) }
]

const FILTER_METATADA = ['health']

const useState = inject('state')

const chartState = reactive({
  data: {
    labels: [],
    datasets: []
  },
  options: {
    responsive: true,
    scales: {
      x: {
        stacked: true
      },
      y: {
        stacked: true
      }
    }
  }
})

const filterMetadata = (metadata) => {
  const newObj = { ...metadata }

  FILTER_METATADA.forEach(key => delete newObj[key])

  return newObj
}

watch(() => useState.metadata, metadata => {
  const data = filterMetadata(metadata)
  const objects = Object.values(data).reverse()
  const labels = Object.keys(data).map(label => humanize(label))
  const datasets = DATASET_LABELS.map(({ label, property, backgroundColor }) => ({
    label,
    data: objects.map((obj, index) => obj.freshness[property] || 0),
    backgroundColor
  }))

  chartState.data = {
    datasets,
    labels
  }
})

</script>
