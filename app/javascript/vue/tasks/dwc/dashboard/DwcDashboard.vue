<template>
  <div >
    <vue-chart
    style="max-height: 500px"
      type="bar"
      :data="chartState.data"
      :options="chartState.options"/>
  </div>
</template>
<script setup>

import { onBeforeMount, ref, reactive, watch } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import { humanize } from 'helpers/strings.js'
import VueChart from 'components/ui/Chart/index.vue'

const DATASET_LABELS = [
  { label: 'never', property: 'never', backgroundColor: 'red' },
  { label: 'One day',property: 'one_day', backgroundColor: 'blue' },
  { label: 'One week', property: 'one_week', backgroundColor: 'green' },
  { label: 'One month', property: 'one_month', backgroundColor: 'purple' },
  { label: 'One year', property: 'one_year', backgroundColor: 'orange' }
]

const metadata = ref({})
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

watch(metadata, metadata => {
  const objects = Object.values(metadata)
  const labels = Object.keys(metadata).map(label => humanize(label))
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

onBeforeMount(async () => {
  metadata.value = (await DwcOcurrence.metadata()).body.metadata
})

</script>
