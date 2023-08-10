<template>
  <div>
    <div
      class="horizontal-left-content gap-small margin-medium-bottom margin-medium-top"
    >
      <input
        type="text"
        v-model="name"
      />
      <VBtn
        :disabled="!name.length"
        color="update"
        medium
        @click="updateTaxonName"
      >
        Update name
      </VBtn>
    </div>
    <FormCitation
      :submit-button="{
        color: 'create',
        label: citation.id ? 'Update' : 'Add'
      }"
      :original="false"
      v-model="citation"
      @submit="saveCitation"
    >
    </FormCitation>
    <DisplayList
      edit
      :list="citations"
      label="citation_source_body"
      @edit="(item) => (citation = item)"
      @delete="removeCitation"
    />
  </div>
</template>

<script setup>
import { TAXON_NAME } from '@/constants'
import { TaxonName, Citation } from '@/routes/endpoints'
import { ref, watch, computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import DisplayList from '@/components/displayList.vue'

const props = defineProps({
  relationship: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:name', 'reset'])
const name = ref('')
const citations = ref([])
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
    name: name.value
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

async function saveCitation(citation) {
  const payload = {
    ...citation,
    citation_object_type: TAXON_NAME,
    citation_object_id: taxonId.value,
    is_original: true
  }
  const response = citation.id
    ? await Citation.update(citation.id, { citation: payload })
    : await Citation.create({ citation: payload })

  TW.workbench.alert.create('Citation was successfully saved.', 'notice')
}

function removeCitation(item) {
  Citation.destroy(item.id).then((_) => {
    citation.value = {}
    TW.workbench.alert.create('Citation was successfully destroyed.', 'notice')
  })
}
</script>
