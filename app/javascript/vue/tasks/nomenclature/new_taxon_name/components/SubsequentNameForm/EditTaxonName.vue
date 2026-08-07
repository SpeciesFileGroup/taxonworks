<template>
  <div>
    <div
      class="horizontal-left-content gap-small margin-medium-bottom margin-medium-top"
    >
      <input
        type="text"
        v-model="name"
      />
    </div>
    <FormCitation
      class="margin-medium-bottom"
      :original="false"
      v-model="citation"
      inline-clone
      @submit="updateTaxonName"
    >
    </FormCitation>
    <div class="horizontal-left-content gap-small margin-medium-top">
      <VBtn
        color="create"
        medium
        @click="updateTaxonName"
      >
        Save
      </VBtn>
      <VBtn
        color="primary"
        medium
        @click="emit('reset')"
      >
        New
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { TAXON_NAME } from '@/constants'
import { TaxonName, Citation } from '@/routes/endpoints'
import { ref, watch, computed } from 'vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  relationship: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:name', 'reset'])
const name = ref('')
const citation = ref({})

const taxonId = computed(() => props.relationship.subject_taxon_name_id)

watch(
  taxonId,
  (newVal) => {
    TaxonName.find(newVal).then(({ body }) => {
      name.value = body.name
    })
    Citation.where({
      citation_object_type: TAXON_NAME,
      citation_object_id: newVal
    }).then(({ body }) => {
      citation.value = body.find((item) => item.is_original) || {}
    })
  },
  { immediate: true }
)

function updateTaxonName() {
  const payload = {
    name: name.value,
    origin_citation_attributes: {}
  }

  if (citation.value.source_id) {
    Object.assign(payload, {
      origin_citation_attributes: {
        ...citation.value
      }
    })
  }

  TaxonName.update(taxonId.value, {
    taxon_name: payload
  })
    .then(({ body }) => {
      emit('update:name', body.name)
      TW.workbench.alert.create(
        'Taxon name was successfully updated.',
        'notice'
      )
    })
    .catch((e) => {})
}

async function saveCitation(item) {
  const payload = {
    ...item,
    citation_object_type: TAXON_NAME,
    citation_object_id: taxonId.value,
    is_original: true
  }
  const response = item.id
    ? Citation.update(item.id, { citation: payload })
    : Citation.create({ citation: payload })

  response.then(({ body }) => {
    citation.value = body
    TW.workbench.alert.create('Citation was successfully saved.', 'notice')
  })
}
</script>
