<template>
  <div>
    <div class="flex-col gap-small margin-medium-bottom">
      <BiologicalAssociationObject
        :item="related"
        label="Choose related..."
        v-model:lock="relatedLock"
        @remove="() => (related = null)"
      />
      <BiologicalAssociationObject
        :item="relationship"
        label="Choose relationship..."
        v-model:lock="relationshipLock"
        @remove="() => (relationship = null)"
      />
    </div>
    <BiologicalAssociationRelated
      v-if="!related"
      @select="(item) => (related = item)"
    />
    <BiologicalAssociationRelationship
      v-if="!relationship"
      @select="(item) => (relationship = item)"
    />
    <FormCitation
      v-model="citation"
      :lock-button="citationLock"
    />
    <VBtn
      class="margin-medium-top"
      :color="buttonColor"
      medium
      :disabled="!related || !relationship"
      @click="
        () => {
          emit('add', makeBiologicalAssociationPayload())
          resetForm()
        }
      "
    >
      {{ biologicalAssociation.id ? 'Update' : 'Add' }}
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { randomUUID } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import BiologicalAssociationRelated from './BiologicalAssociationRelated.vue'
import BiologicalAssociationRelationship from './BiologicalAssociationRelationship.vue'
import BiologicalAssociationObject from './BiologicalAssociationObject.vue'

const emit = defineEmits(['add'])

defineProps({
  buttonColor: {
    type: String,
    default: 'primary'
  }
})

const citationLock = defineModel('citation-lock', {
  type: Boolean,
  default: false
})

const relatedLock = defineModel('related-lock', {
  type: Boolean,
  default: false
})

const relationshipLock = defineModel('relationship-lock', {
  type: Boolean,
  default: false
})

const related = ref(null)
const relationship = ref(null)
const biologicalAssociation = ref({})
const citation = ref(makeCitation())

function makeBiologicalAssociationPayload() {
  const { id, uuid } = biologicalAssociation.value

  return {
    id,
    uuid: uuid || randomUUID(),
    relationship: relationship.value,
    related: related.value,
    citation: citation.value
  }
}

function makeCitation(data = {}) {
  return {
    id: data.id,
    source_id: data.source_id,
    pages: data.pages,
    is_original: null
  }
}

function setBiologicalAssociation(ba) {
  const { id, globalId, uuid } = ba

  biologicalAssociation.value = {
    id,
    globalId,
    uuid
  }

  relationship.value = ba.relationship
  related.value = ba.related
  citation.value = makeCitation(ba.citation)
}

function resetForm() {
  if (!relatedLock.value) {
    related.value = null
  }

  if (!relationshipLock.value) {
    relationship.value = null
  }

  citation.value = citationLock.value
    ? makeCitation({ ...citation.value, id: undefined })
    : makeCitation()

  biologicalAssociation.value = {}
}

defineExpose({
  setBiologicalAssociation,
  resetForm
})
</script>
