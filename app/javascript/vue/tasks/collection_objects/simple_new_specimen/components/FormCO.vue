<template>
  <BlockLayout>
    <template #header>
      <h3>Collection object</h3>
    </template>
    <template #body>
      <div>
        <FormCOPreparationType />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from 'components/layout/BlockLayout.vue'
import FormCOPreparationType from './FormCO/FormCOPreparationType.vue'
</script>
