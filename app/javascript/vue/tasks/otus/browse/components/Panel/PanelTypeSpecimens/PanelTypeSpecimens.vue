<template>
  <PanelLayout
    :status="status"
    :title="`${title} (${collectionObjects.length})`"
    :name="title"
    :spinner="isLoading"
  >
    <div
      v-if="types.length"
      class="separate-top"
    >
      <ul class="no_bullets">
        <li
          v-for="co in collectionObjects"
          :key="co.collection_objects_id"
        >
          <PanelTypeSpecimensInfo
            :types="
              types.filter(
                (item) => co.collection_objects_id === item.collection_object_id
              )
            "
            :specimen="co"
            :otu="otu"
          />
        </li>
      </ul>
    </div>
    <div v-else>No type specimen records available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { CollectionObject, TypeMaterial, TaxonName } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import PanelTypeSpecimensInfo from './PanelTypeSpecimensInfo.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  taxonName: {
    type: Object,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Type specimens'
  }
})

const types = ref([])
const collectionObjects = ref([])
const isLoading = ref(false)

function createObject(list, position) {
  const tmp = {}

  list.column_headers.forEach((item, index) => {
    tmp[item] = list.data[position][index]
  })

  return tmp
}

async function loadTypeSpecimens(otus, currentOtu) {
  isLoading.value = true

  try {
    const taxonNameIds = [
      ...new Set(otus.map((otu) => otu.taxon_name_id))
    ].filter(Boolean)

    if (!taxonNameIds.length) return

    const { body: taxonNames } = await TaxonName.all({
      taxon_name_id: taxonNameIds
    })

    const currentTaxon = taxonNames.find(
      (taxon) => currentOtu.taxon_name_id === taxon.id
    )

    const relevantTaxonNames = currentTaxon?.cached_is_valid
      ? taxonNames
      : [currentTaxon].filter(Boolean)

    for (const taxon of relevantTaxonNames) {
      const { body: dwcData } = await CollectionObject.dwcIndex({
        type_specimen_taxon_name_id: taxon.id,
        per: 500,
        extend: ['origin_citation', 'citations', 'source']
      })

      collectionObjects.value = collectionObjects.value.concat(
        dwcData.data.map((_, index) => createObject(dwcData, index))
      )

      const { body: typeMaterials } = await TypeMaterial.where({
        protonym_id: taxon.id,
        extend: ['origin_citation', 'citations', 'source']
      })

      types.value = types.value.concat(typeMaterials)
    }
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      types.value = []
      collectionObjects.value = []
      loadTypeSpecimens(newVal, props.otu)
    }
  },
  { immediate: true }
)
</script>
