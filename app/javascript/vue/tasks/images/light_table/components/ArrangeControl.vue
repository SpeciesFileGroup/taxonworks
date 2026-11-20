<template>
  <VBtn
    variant="outline"
    color="default"
    :title="`Stack images with the same ${option.label} into decks, side by side`"
    :disabled="!items.length || isLoading"
    @click="arrange"
  >
    {{ isLoading ? 'Arranging...' : `Arrange by ${option.label}` }}
  </VBtn>
</template>

<script setup>
import { ARRANGE_BY, useArrange } from '../composables/useArrange'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['arrange'])

const option = ARRANGE_BY[0]
const { isLoading, stacksBy } = useArrange()

async function arrange() {
  try {
    emit('arrange', await stacksBy(option.value, props.items))
  } catch {
    TW.workbench.alert.create('Images could not be arranged.', 'error')
  }
}
</script>
