<template>
  <div>
    <fieldset>
      <legend>Synonym type</legend>
      <select
        v-model="selectedType"
        class="full_width"
      >
        <option
          :value="undefined"
          disabled
        >
          Select synonym type
        </option>
        <template
          v-for="(codeTypes, code) in synonymTypes"
          :key="code"
        >
          <optgroup :label="code.toUpperCase()">
            <option
              v-for="(info, typeName) in codeTypes"
              :key="typeName"
              :value="typeName"
            >
              {{ info.subject_status_tag }}
            </option>
          </optgroup>
        </template>
      </select>
    </fieldset>

    <div class="horizontal-left-content gap-small margin-large-top margin-large-bottom">
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="TaxonNameRelationship.batchUpdate"
        :payload="payload"
        :disabled="!selectedType"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="TaxonNameRelationship.batchUpdate"
        :payload="payload"
        :disabled="!selectedType"
        @finalize="() => { updateBatchRef.openModal() }"
      />
    </div>
  </div>
</template>

<script setup>
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { ref, computed, onMounted } from 'vue'

const SYNONYM_BASES = [
  'TaxonNameRelationship::Iczn::Invalidating::Synonym',
  'TaxonNameRelationship::Iczn::Invalidating::Usage',
  'TaxonNameRelationship::Icn::Unaccepting::Synonym',
  'TaxonNameRelationship::Icn::Unaccepting::Usage',
  'TaxonNameRelationship::Icnp::Unaccepting::Synonym',
  'TaxonNameRelationship::Icnp::Unaccepting::Usage',
  'TaxonNameRelationship::Icvcn::Unaccepting'
]

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const selectedType = ref(undefined)
const synonymTypes = ref({})

const payload = computed(() => ({
  taxon_name_relationship_query: props.parameters,
  taxon_name_relationship: {
    type: selectedType.value
  }
}))

onMounted(() => {
  TaxonNameRelationship.types().then(({ body }) => {
    const filtered = {}
    for (const code in body) {
      const allForCode = body[code].all
      if (!allForCode) continue
      const synonymsForCode = {}
      for (const typeName in allForCode) {
        if (SYNONYM_BASES.some((base) => typeName.startsWith(base))) {
          synonymsForCode[typeName] = allForCode[typeName]
        }
      }
      if (Object.keys(synonymsForCode).length) {
        filtered[code] = synonymsForCode
      }
    }
    synonymTypes.value = filtered
  })
})

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} taxon name relationships queued for updating.`
    : `${data.updated.length} taxon name relationships were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
