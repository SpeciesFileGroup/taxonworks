<template>
  <list-common
    filter
    :object-lists="lists.common"
    display="name"
    @add-entry="emit('select', $event)"
    :list-created="created"/>
</template>

<script setup>
import ListCommon from '../../commonList.vue'

const props = defineProps({
  created: {
    type: Array,
    default: () => []
  },

  lists: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
