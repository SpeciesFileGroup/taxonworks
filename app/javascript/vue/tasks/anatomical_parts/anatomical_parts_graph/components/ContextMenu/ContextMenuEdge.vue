<template>
  <div class="graph-context-menu-list-header">Anatomical Parts</div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  edges: {
    type: Object,
    default: () => ({})
  }
})

</script>
