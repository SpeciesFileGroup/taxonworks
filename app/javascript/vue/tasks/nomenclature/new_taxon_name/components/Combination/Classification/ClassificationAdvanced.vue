<template>
  <autocomplete
    :array-list="lists.all"
    label="name"
    min="3"
    time="0"
    placeholder="Search"
    @get-item="emit('select', $event)"
    param="term"/>
</template>

<script setup>
import Autocomplete from 'components/ui/Autocomplete.vue'

const props = defineProps({
  lists: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
