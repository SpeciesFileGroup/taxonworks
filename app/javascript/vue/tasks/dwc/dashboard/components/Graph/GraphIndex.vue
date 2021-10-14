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
import { humanize, capitalize } from 'helpers/strings.js'
import { randomHue } from 'helpers/colors.js'
import VueChart from 'components/ui/Chart/index.vue'

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

const fillDatasetLabels = (freshness) =>
  Object.keys(freshness).map((key, index) => ({
    label: capitalize(humanize(key)),
    property: key,
    backgroundColor: randomHue(index)
  }))

watch(() => useState.metadata, metadata => {
  const data = filterMetadata(metadata)
  const datasetLabels = fillDatasetLabels(data.index.freshness)
  const objects = Object.values(data).reverse()
  const labels = Object.keys(data).map(label => humanize(label))
  const datasets = datasetLabels.map(({ label, property, backgroundColor }) => ({
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
