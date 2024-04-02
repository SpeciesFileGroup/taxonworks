<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Data</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Preview</td>
        <td>
          {{ data.preview ? 'Yes' : 'No' }}
        </td>
      </tr>
      <tr>
        <td>Async</td>
        <td>
          <div
            v-if="data.async"
            class="horizontal-left-content middle gap-small"
          >
            <VIcon
              name="attention"
              color="warning"
              small
            />
            <span class="text-warning-color"
              >Yes. Records will not be updated immediately, they will be
              updated asynchronously.</span
            >
          </div>
          <div v-else>No</div>
        </td>
      </tr>
      <tr>
        <td>Updated</td>
        <td>{{ data.updated.length }}</td>
      </tr>
      <tr>
        <td>Not updated</td>
        <td>{{ data.not_updated.length }}</td>
      </tr>
      <tr>
        <td>Total attempted</td>
        <td>{{ data.total_attempted }}</td>
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
import { computed } from 'vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
})

const previewErrors = computed(() => {
  return Object.entries(props.data?.errors || {}).map(([label, total]) => ({
    label,
    total
  }))
})
</script>
