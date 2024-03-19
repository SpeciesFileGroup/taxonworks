<template>
  <VChart
    ref="root"
    :data="dataset"
    :options="options"
    :plugins="plugins"
    type="bar"
    height="400"
    width="400"
  />
</template>

<script setup>
import { computed, ref } from 'vue'
import { getHexColorFromString } from '@/tasks/biological_associations/biological_associations_graph/utils'
import { convertToTwoDigits } from '@/helpers'
import VChart from '@/components/ui/Chart'

import qs from 'qs'

const props = defineProps({
  data: {
    type: Number,
    required: true
  },

  target: {
    type: String,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  weeksAgo: {
    type: Number,
    required: true
  }
})

const CONFIG = {
  type_materials: {
    url: '/tasks/collection_objects/filter',
    params: {
      type_material: true
    }
  }
}

const root = ref(null)

const dataset = computed(() => makeDataset(props.data))

function formatDate(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  return `${year}-${convertToTwoDigits(month)}-${convertToTwoDigits(day)}`
}

function dayByWeeksAgo(weeks) {
  const date = new Date()
  const days = weeks * 7

  date.setDate(date.getDate() - days)

  return formatDate(date)
}

function makeDataset({ data, title }) {
  return {
    labels: data.map((arr) => arr[1]),
    datasets: [
      {
        label: title,
        data: data.map((arr) => arr[2]),
        backgroundColor: data.map((arr) => getHexColorFromString(arr[1]))
      }
    ]
  }
}

function loadTask(index) {
  const { params, url } = CONFIG[props.target] || {}
  const parameters = {
    user_date_start: dayByWeeksAgo(props.weeksAgo),
    user_date_end: formatDate(new Date()),
    user_target: 'created',
    user_id: props.data.data[index][0],
    ...params
  }

  const queryString = qs.stringify(parameters, { arrayFormat: 'brackets' })
  const filterUrl = url
    ? `${url}?${queryString}`
    : `/tasks/${props.target}/filter?${queryString}`

  window.open(filterUrl, '_blank')
}

const options = {
  indexAxis: 'y',
  responsive: false,
  plugins: {
    title: {
      display: true,
      text: props.title
    },

    legend: {
      display: false
    },

    tooltip: {
      display: false
    }
  },
  onClick: (evt, elements) => {
    if (elements.length > 0) {
      const index = elements[0].index

      loadTask(index)
    }
  }
}
</script>
