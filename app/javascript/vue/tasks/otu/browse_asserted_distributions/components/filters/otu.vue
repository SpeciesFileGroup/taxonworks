<template>
  <div>
    <span>Name</span>
    <VAutocomplete
      url="/otus/autocomplete"
      placeholder="Search an OTU"
      param="term"
      label="label_html"
      autofocus
      clear-after
      @get-item="(item) => (otuId = item.id)"
    />
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete'
import { onBeforeMount } from 'vue'

const otuId = defineModel({
  type: [Number, String],
  default: undefined
})

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('otu_id')

  if (/^\d+$/.test(id)) {
    otuId.value = id
  }
})
</script>
