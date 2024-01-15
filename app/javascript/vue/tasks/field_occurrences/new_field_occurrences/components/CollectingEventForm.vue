<template>
  <BlockLayout>
    <template #header>
      <h3>Collecting event</h3>
    </template>
    <template #body>
      <FormCollectingEvent :exclude="[ComponentMap.PrintLabel]" />
    </template>
  </BlockLayout>
</template>

<script setup>
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { ComponentMap } from '@/components/Form/FormCollectingEvent/const/components.js'
</script>
