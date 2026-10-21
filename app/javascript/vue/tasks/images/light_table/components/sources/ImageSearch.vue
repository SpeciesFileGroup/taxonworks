<template>
  <div class="flex-col gap-small">
    <VAutocomplete
      url="/images/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search an image..."
      clear-after
      @select="addImage"
    />
    <VSpinner v-if="isLoading" />
    <p class="text-xs">
      Images are placed as they are, depicting nothing. To place an image as it
      depicts an OTU, use the OTU tab.
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Image } from '@/routes/endpoints'
import { OBJECT_IMAGE } from '../../constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['add'])

const isLoading = ref(false)

function addImage({ id }) {
  isLoading.value = true

  Image.find(id)
    .then(({ body }) => {
      emit('add', { objectType: OBJECT_IMAGE, objects: [body] })
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}
</script>
