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
    <FormCitation v-model="citation" />
    <VBtn
      class="margin-medium-top"
      color="primary"
      medium
      :disabled="!related || !relationship"
      @click="() => emit('add', makeBiologicalAssociationPayload())"
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
import makeCitation from '@/factory/Citation.js'

const emit = defineEmits(['add'])

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

function setBiologicalAssociation(ba) {
  const { related, relationship, ...rest } = ba

  citation.value = makeCitation()
  biologicalAssociation.value = rest

  relationship.value = relationship
  related.value = ba.related
}

function resetForm() {
  if (!relatedLock.value) {
    related.value = null
  }

  if (!relationshipLock.value) {
    relationship.value = null
  }

  biologicalAssociation.value = ref({})
}

defineExpose({
  setBiologicalAssociation,
  resetForm
})
</script>
