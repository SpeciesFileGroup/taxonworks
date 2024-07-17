<template>
  <table class="table-striped">
    <thead>
      <th>Related</th>
      <th class="w-2">Total</th>
    </thead>
    <tbody>
      <tr
        v-for="(item, key) in metadata"
        :key="key"
      >
        <td>{{ item.name }}</td>
        <td>{{ item.total }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Unify } from '@/routes/endpoints'

const props = defineProps({
  globalId: {
    type: String,
    required: true
  }
})

const metadata = ref({})

watch(
  () => props.globalId,
  (newVal) => {
    Unify.metadata({ global_id: newVal }).then(({ body }) => {
      metadata.value = body
    })
  },
  { immediate: true }
)
</script>
