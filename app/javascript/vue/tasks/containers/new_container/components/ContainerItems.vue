<template>
  <BlockLayout>
    <template #header>
      <h3>Container items</h3>
    </template>
    <template #body>
      <DisplayList
        :list="containerItems"
        label="label"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import DisplayList from '@/components/displayList.vue'

defineProps({
  containerItems: {
    type: Array,
    default: () => []
  }
})
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
