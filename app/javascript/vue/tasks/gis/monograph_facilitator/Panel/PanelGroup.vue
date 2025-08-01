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
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import useStore from '../store/store.js'

const groupBy = [
  {
    label: 'Taxon determination'
  }
]

const store = useStore()
</script>
