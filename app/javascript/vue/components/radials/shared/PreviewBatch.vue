<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Data</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(value, key) in previewData"
        :key="key"
      >
        <td>{{ humanize(key) }}</td>
        <td>{{ value }}</td>
      </tr>
    </tbody>
  </table>
  <table
    v-if="previewErrors.length"
    class="table-striped full_width"
  >
    <thead>
      <tr>
        <th>Errors</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in previewErrors"
        :key="item.label"
      >
        <td>{{ item.label }}</td>
        <td>{{ item.total }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { humanize } from '@/helpers'
import { computed } from 'vue'

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
})

const previewData = computed(() => {
  const { data } = props

  return {
    preview: data.preview ? 'Yes' : 'No',
    async: data.async ? 'Yes' : 'No',
    updated: data.updated.length,
    not_updated: data.not_updated.length,
    total_attempted: data.total_attempted
  }
})

const previewErrors = computed(() => {
  return Object.entries(props.data.errors).map(([label, total]) => ({
    label,
    total
  }))
})
</script>
