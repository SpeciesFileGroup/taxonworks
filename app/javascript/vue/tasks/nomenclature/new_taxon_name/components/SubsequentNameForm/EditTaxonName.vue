<template>
  <div>
    <div>
      Editing relationship:
      <span v-html="relationship.object_tag" />
      <VBtn
        class="margin-small-left"
        circle
        color="primary"
        @click="emit('reset')"
      >
        <VIcon
          small
          name="undo"
        />
      </VBtn>
    </div>
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
      v-model="citation"
      @submit="saveCitation"
    >
      <template #footer>
        <VBtn
          class="margin-small-left"
          color="primary"
          medium
          @click="citation = {}"
        >
          New
        </VBtn>
      </template>
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
import { TAXON_NAME_RELATIONSHIP } from '@/constants'
import { TaxonName, Citation } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
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

watch(
  () => props.relationship.subject_taxon_name_id,
  (newVal) => {
    TaxonName.find(newVal).then(({ body }) => {
      name.value = body.name
    })
    Citation.where({
      citation_object_type: TAXON_NAME_RELATIONSHIP,
      citation_object_id: props.relationship.id
    }).then(({ body }) => {
      citations.value = body
    })
  },
  { immediate: true }
)

function updateTaxonName() {
  const payload = {
    name: name.value
  }

  TaxonName.update(props.relationship.subject_taxon_name_id, {
    taxon_name: payload
  })
    .then((body) => {
      emit('update:name', body.name)
    })
    .catch((e) => {})
}

async function saveCitation(citation) {
  const payload = {
    ...citation,
    citation_object_type: TAXON_NAME_RELATIONSHIP,
    citation_object_id: props.relationship.id
  }
  const response = citation.id
    ? await Citation.update(citation.id, { citation: payload })
    : await Citation.create({ citation: payload })

  addToArray(citations.value, response.body)

  TW.workbench.alert.create('Citation was successfully saved.', 'notice')
}

function removeCitation(item) {
  Citation.destroy(item.id).then((_) => {
    removeFromArray(citations.value, item)
    TW.workbench.alert.create('Citation was successfully destroyed.', 'notice')
  })
}
</script>
