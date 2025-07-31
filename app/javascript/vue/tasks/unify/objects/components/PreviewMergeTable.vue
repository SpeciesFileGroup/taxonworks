<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th>Related</th>
        <th class="w-2">Total</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="({ name, total }, key) in related"
        :key="key"
      >
        <td>
          <div class="horizontal-left-content middle gap-small">
            <span>{{ name }}</span>
            <VIcon
              v-if="response[key]?.errors"
              name="attention"
              color="attention"
              x-small
            />
          </div>
        </td>
        <td>{{ total }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  keepMetadata: {
    type: Object,
    required: true
  },

  destroyMetadata: {
    type: Object,
    required: true
  },

  response: {
    type: Object,
    default: () => ({})
  }
})

const related = computed(() => {
  return mergeObjects(
    mergeObjects({}, props.keepMetadata),
    props.destroyMetadata
  )
})

function mergeObjects(data, obj) {
  for (const key in obj) {
    const currentData = data[key]
    const { total, name } = obj[key]

    data[key] = currentData
      ? { name, total: currentData.total + total }
      : { name, total }
  }

  return data
}
</script>
