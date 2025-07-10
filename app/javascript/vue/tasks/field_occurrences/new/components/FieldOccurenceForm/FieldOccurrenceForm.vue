<template>
  <BlockLayout>
    <template #header>
      <h3>Field occurrence</h3>
    </template>
    <template #body>
      <div class="flex-wrap-column gap-medium">
        <FieldTotal v-model="store.fieldOccurrence" />
        <FieldAbsent v-model="store.fieldOccurrence" />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FieldAbsent from './FieldIsAbsent.vue'
import FieldTotal from './FieldTotal.vue'
import useStore from '../../store/fieldOccurrence.js'

const store = useStore()
</script>
