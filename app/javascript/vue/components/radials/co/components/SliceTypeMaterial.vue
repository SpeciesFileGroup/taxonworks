<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <div>
      <label>Species name</label>
      <VAutocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        clear-after
        :add-params="{
          'type[]': 'Protonym',
          'nomenclature_group[]': ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
        }"
        @get-item="({ id }) => setTaxonName(id)"
      />
      <SmartSelectorItem
        v-if="taxonName"
        :item="taxonName"
        label="object_tag"
        @unset="unsetTaxonName"
      />
    </div>

    <div
      v-if="taxonName && !isCodeSupported"
      class="feedback feedback-danger margin-medium-top"
    >
      Type designations are not currently supported here for the
      {{ taxonName.nomenclatural_code || 'unrecognized' }} nomenclatural
      code.
    </div>

    <div
      v-else-if="pluralizableTypes.length"
      class="margin-medium-top"
    >
      <label>Type</label>
      <ul class="no_bullets">
        <li
          v-for="type in pluralizableTypes"
          :key="type"
        >
          <label class="capitalize cursor-pointer">
            <input
              v-model="typeType"
              :value="type"
              name="type-type"
              type="radio"
            />
            {{ type }}
          </label>
        </li>
      </ul>
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!isPayloadValid || isCountExceeded"
        confirmation-word="UPDATE"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!isPayloadValid || isCountExceeded"
        @finalize="
          () => {
            updateBatchRef.openModal()
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { CollectionObject, TaxonName, TypeMaterial } from '@/routes/endpoints'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import updateMessage from '../utils/updateMessage.js'

const MAX_LIMIT = 1000

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const taxonName = ref(null)
const typeType = ref(null)
const types = ref({})

const isCodeSupported = computed(
  () => !!types.value[taxonName.value?.nomenclatural_code]
)

const pluralizableTypes = computed(() =>
  getPluralizableTypes(types.value[taxonName.value?.nomenclatural_code])
)

const isPayloadValid = computed(
  () => !!taxonName.value?.id && !!typeType.value
)

const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    type_materials_attributes: [
      {
        protonym_id: taxonName.value?.id,
        type_type: typeType.value
      }
    ]
  }
}))

TypeMaterial.types().then(({ body }) => {
  types.value = body
})

function setTaxonName(id) {
  TaxonName.find(id).then(({ body }) => {
    taxonName.value = body
    typeType.value = null
  })
}

function unsetTaxonName() {
  taxonName.value = null
  typeType.value = null
}

function getPluralizableTypes(codeTypes) {
  if (!codeTypes) return []

  return Object.entries(codeTypes).reduce((list, [type, klass]) => {
    if (klass === 'Lot') {
      const singularType = type.replace(/s$/, '')

      if (codeTypes[singularType] === 'Specimen') {
        list.push(singularType, type)
      }
    }

    return list
  }, [])
}
</script>
