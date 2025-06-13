<template>
  <div>
    <h3>Otu</h3>
    <VAutocomplete
      url="/otus/autocomplete"
      placeholder="Search an OTU"
      param="term"
      label="label_html"
      autofocus
      :clear-after="true"
      @get-item="(otu) => { otuId = otu.id }"
    />
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete'
import { Otu } from '@/routes/endpoints'
import { defineModel, onMounted } from 'vue'

const otuId = defineModel({
  type: [String, Number],
  default: undefined
})

onMounted(() => {
  getParams()
})

function getParams() {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('otu_id')

  if (/^\d+$/.test(id)) {
    loadOtu(id)
  }
}

function loadOtu(id) {
  Otu.find(id).then(({ otu }) => {
    otuId.value = otu.id
  })
}
</script>
