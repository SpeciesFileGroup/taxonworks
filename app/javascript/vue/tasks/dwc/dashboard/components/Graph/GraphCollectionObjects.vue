<template>
  <div>
    <h2>Index versions</h2>
    <vue-chart
      style="max-height: 500px"
      type="bar"
      :data="chartState.data"
      :options="chartState.options"/>
  </div>
</template>
<script setup>

import { reactive, ref, watch, onBeforeMount } from 'vue'
import { DwcOcurrence, CollectionObject } from 'routes/endpoints'
import { randomHue } from 'helpers/colors.js'
import VueChart from 'components/ui/Chart/index.vue'

const versionsResponse = ref([])
const chartState = reactive({
  data: {
    labels: [],
    datasets: []
  },
  options: {
    responsive: true,
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }
})

watch(versionsResponse, data => {
  const dates = data.map(date => date.split(' ')[0])
  const coRequests = dates.map(date => CollectionObject.where({
    dwc_indexed: true,
    user_date_start: date,
    user_date_end: dates[0],
    per: 1
  }))

  Promise.all(coRequests).then(responses => {
    const counts = responses.map(r => Number(r.headers['pagination-total']))

    chartState.data = {
      labels: dates,
      datasets: counts.map((count, index) =>
        ({
          label: 'Collection object',
          data: [count],
          backgroundColor: randomHue(index + 1)
        })
      )
    }
  })
})

onBeforeMount(async () => {
  versionsResponse.value = (await DwcOcurrence.indexVersion()).body
})

</script>
