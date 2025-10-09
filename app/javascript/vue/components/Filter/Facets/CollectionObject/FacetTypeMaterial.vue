<template>
  <FacetContainer>
    <h3>Types</h3>
    <h4>Nomenclature code</h4>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="(_, key) in types"
          :key="key"
        >
          <label class="uppercase">
            <input
              type="radio"
              :value="key"
              name="nomenclature-code-type"
              v-model="nomenclatureCode"
            />
            {{ key }}
          </label>
        </li>
      </ul>
    </div>
    <div
      v-if="nomenclatureCode"
      class="field"
    >
      <h4>Types</h4>
      <ul class="no_bullets">
        <li
          v-for="(_, type) in types[nomenclatureCode]"
          :key="type"
        >
          <label class="capitalize cursor-pointer">
            <input
              v-model="selectedTypes"
              :value="type"
              name="type-type"
              type="checkbox"
            />
            {{ type }}
          </label>
        </li>
      </ul>
    </div>
    <div>
      <h4>Taxon name</h4>
      <VAutocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        clear-after
        placeholder="Search a taxon name..."
        :add-params="{
          'type[]': 'Protonym',
          'nomenclature_group[]': 'SpeciesGroup'
        }"
        @get-item="({ id }) => setTaxonName(id)"
      />
      <SmartSelectorItem
        v-if="taxonName"
        :item="taxonName"
        label="object_tag"
        @unset="taxonName = undefined"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount, nextTick } from 'vue'
import { TaxonName, TypeMaterial } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const emit = defineEmits(['update:modelValue'])

const nomenclatureCode = ref()
const types = ref({})
const taxonName = ref(null)
const selectedTypes = ref([])

watch(nomenclatureCode, () => {
  selectedTypes.value = []
})

watch(
  () => params.value.is_type,
  (newVal) => {
    if (!newVal) {
      selectedTypes.value = []
    }
  }
)

watch(selectedTypes, (newVal) => {
  params.value.is_type = newVal
})

watch(
  () => params.value.type_specimen_taxon_name_id,
  (newId, oldVal) => {
    if (oldVal && !newId) {
      taxonName.value = null
    }
  }
)

onBeforeMount(() => {
  const taxonId = params.value.type_specimen_taxon_name_id
  const isType = params.value.is_type

  TypeMaterial.types().then(({ body }) => {
    types.value = body

    if (Array.isArray(isType)) {
      const [code] = Object.entries(body).find(([_, typeObj]) => {
        const types = Object.keys(typeObj)

        return isType.every((type) => types.includes(type))
      })

      nomenclatureCode.value = code
      nextTick(() => {
        selectedTypes.value = [...isType]
      })
    }
  })

  if (taxonId) {
    setTaxonName(taxonId)
  }
})

function setTaxonName(id) {
  TaxonName.find(id)
    .then(({ body }) => {
      taxonName.value = body
      params.value.type_specimen_taxon_name_id = id
    })
    .catch(() => {})
}
</script>
