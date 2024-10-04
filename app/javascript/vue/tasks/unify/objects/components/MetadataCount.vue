<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th
          class="w-2"
          v-if="checkboxes"
        >
          <input
            type="checkbox"
            v-model="selectAll"
          />
        </th>
        <th>Related</th>
        <th class="w-2">Total</th>
        <th
          v-if="mergeItem"
          class="w-2"
        >
          Merge
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="({ name, total }, key) in item.metadata"
        :key="key"
        @click="() => checkboxes && toggleOnly(key)"
      >
        <td v-if="checkboxes">
          <input
            type="checkbox"
            :value="key"
            v-model="only"
          />
        </td>
        <td>{{ name }}</td>
        <td>{{ total }}</td>
        <td
          v-if="mergeItem"
          v-html="getTotalWithMerge(total, key)"
        />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, nextTick, watch } from 'vue'
import { Unify } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'

const props = defineProps({
  mergeItem: {
    type: Object,
    default: undefined
  },

  checkboxes: {
    type: Boolean,
    default: false
  }
})

const item = defineModel({
  type: Object,
  default: () => ({})
})

const only = defineModel('only', {
  type: Array,
  default: undefined
})

watch(
  () => item.value.global_id,
  (newVal) => {
    if (!item.value.metadata) {
      loadMetadata(newVal)
    } else {
      nextTick(() => {
        only.value = Object.keys(item.value.metadata)
      })
    }
  },
  { immediate: true }
)

const selectAll = computed({
  get: () =>
    only.value.length === Object.keys(item.value?.metadata || {}).length,
  set: (value) => {
    only.value = value ? Object.keys(item.value?.metadata) : []
  }
})

function loadMetadata(globalId) {
  const obj = item.value

  Unify.metadata({ global_id: globalId }).then(({ body }) => {
    obj.metadata = body
    only.value = Object.keys(body)
  })
}

function getTotalWithMerge(count, key) {
  const onlyLength = only.value?.length
  const { total = 0 } = props.mergeItem?.metadata?.[key] || {}

  console.log(
    !onlyLength || (onlyLength && only.value.includes(key)),
    !onlyLength,
    onlyLength && only.value.includes(key)
  )

  return !onlyLength || (onlyLength && only.value.includes(key))
    ? `<b class="text-update-color">${total + count}</b>`
    : count
}

function toggleOnly(key) {
  if (only.value.includes(key)) {
    removeFromArray(only.value, key, { primitive: true })
  } else {
    addToArray(only.value, key, { primitive: true })
  }
}

defineExpose({
  loadMetadata
})
</script>
