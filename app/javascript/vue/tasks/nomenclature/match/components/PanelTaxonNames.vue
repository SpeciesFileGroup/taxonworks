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
        :disabled="!lines.length"
        color="primary"
        data-help="Only the first 5,000 rows will be processed and returned"
        @click="removeAuthors"
      >
        Remove authors
      </VBtn>
      <span
        v-if="removeAuthorsWarn && text"
        class="vertical-center margin-small-left"
      >
        <VIcon
          small
          name="attention"
          color="attention"
        />
        Only {{ REMOVE_AUTHORS_LIMIT }} records processed
      </span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const REMOVE_AUTHORS_LIMIT = 5000

const props = defineProps({
  lines: {
    type: Array,
    required: true
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const text = defineModel('names', {
  type: String,
  required: true
})

const removeAuthorsWarn = ref(false)

function removeAuthors() {
  const payload = {
    names: props.lines
  }

  TaxonName.removeAuthors(payload)
    .then(({ body }) => {
      removeAuthorsWarn.value = body.names.length > REMOVE_AUTHORS_LIMIT
      text.value = body.names.slice(0, REMOVE_AUTHORS_LIMIT).join('\n')
      TW.workbench.alert.create('Removed authors.', 'notice')
    })
    .catch(() => {})
}
</script>

<style lang="css">
.vertical-center {
  vertical-align: bottom;
}
</style>
