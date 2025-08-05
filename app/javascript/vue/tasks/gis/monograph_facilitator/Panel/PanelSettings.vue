<template>
  <BlockLayout>
    <template #header>
      <h3>Settings</h3>
    </template>
    <template #body>
      <label class="d-block">Group by</label>
      <select>
        <option
          v-for="item in groupBy"
          :key="item.label"
        >
          {{ item.label }}
        </option>
      </select>
      <p>Total groups: {{ store.groups.length }}</p>

      <label>
        <input
          type="checkbox"
          v-model="autoHide"
        />
        Auto-hide unselected
      </label>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import useStore from '../store/store.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const groupBy = [
  {
    label: 'Taxon determination'
  }
]

const store = useStore()
const autoHide = ref(false)

watch(
  () => store.selectedIds,
  () => {
    if (autoHide.value) {
      store.hideUnselected()
    }
  },
  { deep: true }
)

watch(autoHide, (newVal) => {
  if (newVal && store.selectedIds.length) {
    store.hideUnselected()
  }
})
</script>
