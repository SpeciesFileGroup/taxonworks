<template>
  <VBtn
    icon
    variant="tonal"
    color="primary"
    title="Browse taxon names"
    @click="redirect()"
    @contextmenu.prevent="redirect(true)"
    >
    <IconHexagonArrow class="w-4 h-4 icon-flip" />
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import { Otu } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants'
import { RouteNames } from '@/routes/routes.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconHexagonArrow from '@/components/Icon/IconHexagonArrow.vue'

const props = defineProps({
  objectId: {
    type: [String, Number],
    required: true
  },

  klass: {
    type: String,
    default: 'TaxonName'
  }
})

const isLoading = ref(false)

function redirect(newTab) {
  if (isLoading.value) return

  isLoading.value = true
  if (props.klass === TAXON_NAME) {
    openBrowse(props.objectId, newTab)
  } else {
    Otu.find(props.objectId).then((response) => {
      if (response.body.length) {
        openBrowse(response.body[0].taxon_name_id, newTab)
      }
    })
  }
}

function openBrowse(id, newTab = false) {
  window.open(
    `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`,
    newTab ? '_blank' : '_self'
  )
}
</script>
