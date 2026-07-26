<template>
  <div class="field">
    <VAutocomplete
      url="/organizations/autocomplete"
      param="term"
      label="label_html"
      display="label"
      min="2"
      clear-after
      placeholder="Add an existing organization to this project"
      @get-item="(item) => emit('select', item)"
    />
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'

const emit = defineEmits(['select'])
</script>
