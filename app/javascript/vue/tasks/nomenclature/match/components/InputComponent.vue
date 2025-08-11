<template>
  <div class="panel content">
    <h3>Taxon names ({{ lines.length }})</h3>
    <div>
      <textarea
        v-model="text"
        class="full_width"
        placeholder="Write names..."
        rows="10"
      />
      <label class="middle">
        <input
          type="checkbox"
          v-model="params.name_exact"
        />
        Exact
      </label>
      <VBtn
        class="margin-small-top"
        :disabled="!text"
        color="primary"
        @click="removeAuthors"
      >
        Remove authors
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const params = defineModel({
  type: Object,
  required: true
})

const text = defineModel('names', {
  type: String,
  required: true
})

const lines = computed(() =>
  text.value.split('\n').filter((line) => line.trim())
)

function removeAuthors() {
  const payload = {
    names: lines.value
  }

  TaxonName.removeAuthors(payload)
    .then(({ body }) => {
      text.value = body.names.join('\n')
      TW.workbench.alert.create('Removed authors.', 'notice')
    })
    .catch(() => {})
}
</script>
