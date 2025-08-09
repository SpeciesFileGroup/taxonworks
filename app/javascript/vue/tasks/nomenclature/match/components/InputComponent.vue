<template>
  <div>
    <textarea
      v-model="text"
      class="full_width"
      placeholder="Write names..."
      rows="10"
    />
  </div>

  <VBtn
    :disabled="!text"
    @click="removeAuthors"
    color="primary"
    class="margin-small-top"
  >
    Remove authors
  </VBtn>
</template>

<script setup>
import { ref, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { TaxonName } from '@/routes/endpoints'

const text = ref(undefined)

const emits = defineEmits(['lines'])

watch(text, (newVal) => {
  emits('lines', newVal.split('\n').filter(line => line.trim().length))
})

function removeAuthors() {
  const payload = {
    names: text.value.split('\n'),
  }
  TaxonName.removeAuthors(payload)
    .then(({ body }) => {
      text.value = body.names.join('\n')
      TW.workbench.alert.create('Removed authors.', 'notice')
    })
    .catch(() => {})
}

</script>
