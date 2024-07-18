<template>
  <table class="table-striped">
    <thead>
      <th>Related</th>
      <th class="w-2">Total</th>
    </thead>
    <tbody>
      <tr
        v-for="({ name, total }, key) in item.metadata"
        :key="key"
      >
        <td>{{ name }}</td>
        <td>{{ total }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { watch } from 'vue'
import { Unify } from '@/routes/endpoints'

const item = defineModel({
  type: Object,
  default: () => ({})
})

watch(
  () => item.value.global_id,
  (newVal) => {
    const obj = item.value

    if (!obj.metadata) {
      Unify.metadata({ global_id: newVal }).then(({ body }) => {
        obj.metadata = body
      })
    }
  },
  { immediate: true }
)
</script>
