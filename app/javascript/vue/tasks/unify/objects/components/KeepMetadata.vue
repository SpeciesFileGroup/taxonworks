<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Related</th>
        <th class="w-2">Total</th>
        <th
          v-if="mergeItem"
          class="w-2"
        >
          Unify
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="({ name, total }, key) in item._metadata"
        :key="key"
      >
        <td>{{ name }}</td>
        <td>{{ total }}</td>
        <td
          v-if="mergeItem"
          v-html="getTotalWithMerge(total, key)"
        />
      </tr>
      <tr
        v-for="{ name, total } in rows"
        :key="name"
        class="text-update-color font-bold"
      >
        <td>{{ name }}</td>
        <td />
        <td>{{ total }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch } from 'vue'
import { Unify } from '@/routes/endpoints'

const props = defineProps({
  mergeItem: {
    type: Object,
    default: undefined
  },

  only: {
    type: Array,
    default: () => []
  }
})

const item = defineModel({
  type: Object,
  default: () => ({})
})

const rows = computed(() => {
  if (!props.mergeItem?._metadata || !item.value?._metadata) {
    return []
  }

  const metadata = Object.keys(item.value._metadata)

  return Object.entries(props.mergeItem._metadata)
    .filter(([key]) => props.only.includes(key) && !metadata.includes(key))
    .map(([, value]) => ({ ...value }))
})

watch(
  () => item.value.global_id,
  (newVal) => {
    if (!item.value._metadata) {
      loadMetadata(newVal)
    }
  },
  { immediate: true }
)

function loadMetadata(globalId) {
  const obj = item.value

  Unify.metadata({ global_id: globalId }).then(({ body }) => {
    obj._metadata = body
  })
}

function getTotalWithMerge(count, key) {
  const onlyLength = props.only?.length
  const { total = 0 } = props.mergeItem?._metadata?.[key] || {}

  return !onlyLength || (onlyLength && props.only.includes(key))
    ? `<b class="text-update-color">${total + count}</b>`
    : count
}

defineExpose({
  loadMetadata
})
</script>
