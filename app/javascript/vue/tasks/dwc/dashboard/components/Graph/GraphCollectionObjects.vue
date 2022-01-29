<template>
  <div>
    <h2>DwC occurrence record version</h2>
    <vue-chart
      style="max-height: 500px"
      type="bar"
      :data="chartState.data"
      :options="chartState.options"/>
  </div>
</template>
<script setup>

import { reactive, ref, watch, onBeforeMount } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import { randomHue } from 'helpers/colors.js'
import VueChart from 'components/ui/Chart/index.vue'

const DEFAULT_START_DATE = '2000-01-01'
const DEFAULT_PARAMS = {
  dwc_indexed: true,
  per: 1,
  dwc_occurrence_object_type: ['CollectionObject']
}
const versionsResponse = ref([])
const chartState = reactive({
  data: {
    labels: [],
    datasets: []
  },
  options: {
    responsive: true,
    plugins: {
      legend: {
        display: false
      },
      title: {
        display: true,
        text: 'Total collection objects'
      }
    }
  }
})

watch(versionsResponse, data => {
  const dates = [].concat(data.map(date => date.split(' ')[0]), [new Date().toISOString().split('T')[0]])
  const coRequests = dates.map((date, index) => DwcOcurrence.where({
    user_date_start: dates[index - 1] || DEFAULT_START_DATE,
    user_date_end: date,
    ...DEFAULT_PARAMS
  }))

  Promise.all(coRequests).then(responses => {
    const counts = responses.map(r => Number(r.headers['pagination-total']))

    chartState.data = {
      labels: dates,
      datasets: [
        {
          label: 'Collection objects',
          data: counts.map(count => count),
          backgroundColor: dates.map((_, index) => randomHue(index + 1))
        }
      ]
    }
  })
})

onBeforeMount(async () => {
  versionsResponse.value = (await DwcOcurrence.indexVersion()).body
})

</script>
