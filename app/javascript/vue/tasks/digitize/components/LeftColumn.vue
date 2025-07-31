<template>
  <VDraggable
    class="separate-right left-section"
    v-model="componentsOrder"
    :item-key="(item) => item"
    @end="updatePreferences"
  >
    <template #item="{ element }">
      <component
        class="margin-medium-bottom"
        :is="VueComponents[element]"
      />
    </template>
  </VDraggable>
</template>

<script setup>
import VDraggable from 'vuedraggable'
import { useSortComponents } from '../composables/useSortComponents'
import { VueComponents } from '../const/components'

const keyStorage = 'tasks::digitize::LeftColumnOrder'
const componentsSection = 'leftColumn'

const { componentsOrder, updatePreferences } = useSortComponents({
  keyStorage,
  componentsSection
})
</script>
