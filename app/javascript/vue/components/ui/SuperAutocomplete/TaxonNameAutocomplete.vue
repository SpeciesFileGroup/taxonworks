<template>
  <SuperAutocomplete
    v-bind="attrs"
    @expand="(item) => expandRef.setItem(item)"
    @select="(taxon) => emit('select', taxon)"
  />
  <SuperAutocompleteExpansion
    ref="expandRef"
    @create="(taxon) => emit('select', taxon)"
  />
</template>

<script setup>
import { useAttrs, useTemplateRef } from 'vue'
import SuperAutocomplete from './SuperAutocomplete.vue'
import SuperAutocompleteExpansion from './SuperAutocompleteExpansion.vue'

const attrs = useAttrs()

const emit = defineEmits(['select'])

const expandRef = useTemplateRef('expandRef')
</script>
