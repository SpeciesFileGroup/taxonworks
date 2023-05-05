<template>
  <div class="panel content">
    <autocomplete
      class="full_width"
      url="/otus/autocomplete"
      placeholder="Search a otu"
      param="term"
      clear-after="true"
      label="label_html"
      @get-item="($event) => emit('select', $event)"
    />
  </div>
</template>

<script setup>
import Autocomplete from 'components/ui/Autocomplete'

const emit = defineEmits(['select'])
</script>
