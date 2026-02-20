<template>
  <PanelLayout
    :status="status"
    :title="`${title} (${collectionObjects.length})`"
    :name="title"
    :spinner="isLoading"
  >
    <SlidingStack
      v-if="types.length"
      scroll-offset-element="#browse-otu-header"
      :scroll-offset="100"
    >
      <template #master="{ push }">
        <ul class="no_bullets separate-top">
          <li
            v-for="co in collectionObjects"
            :key="co.collection_objects_id"
          >
            <div class="panel margin-small-bottom padding-small">
              <div
                class="cursor-pointer inline"
                @click="
                  push({
                    specimen: co,
                    types: types.filter(
                      (t) => co.collection_objects_id === t.collection_object_id
                    ),
                    otu
                  })
                "
              >
                <VBtn
                  circle
                  color="primary"
                >
                  <VIcon
                    name="arrowRight"
                    x-small
                  />
                </VBtn>
                <span class="margin-small-left">
                  [<span
                    v-html="
                      types
                        .filter(
                          (t) =>
                            co.collection_objects_id === t.collection_object_id
                        )
                        .map((t) => `${t.type_type} of ${t.original_combination}`)
                        .join('; ')
                    "
                  />] - <span v-html="getCeLabel(co)" />
                </span>
              </div>
            </div>
          </li>
        </ul>
      </template>

      <template #detail="{ payload, pop }">
        <div class="padding-small">
          <div class="margin-small-bottom">
            <VBtn
              color="primary"
              medium
              @click="pop"
            >
              <VIcon
                name="arrowLeft"
                x-small
              />
              Back
            </VBtn>
          </div>
          <PanelTypeSpecimensTypeData
            v-for="type in payload.types"
            :key="type.id"
            class="species-information-container"
            :type="type"
            :otu="payload.otu"
          />
          <PanelTypeSpecimensDetail
            class="species-information-container"
            :specimen="payload.specimen"
          />
        </div>
      </template>
    </SlidingStack>

    <div v-else>No type specimen records available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { CollectionObject, TypeMaterial, TaxonName } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import SlidingStack from '@/components/ui/SlidingStack.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import PanelTypeSpecimensTypeData from './PanelTypeSpecimensTypeData.vue'
import PanelTypeSpecimensDetail from './PanelTypeSpecimensDetail.vue'

const LEVELS = ['country', 'stateProvince', 'county']

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

function getCeLabel(co) {
  const areas = []

  LEVELS.forEach((level) => {
    if (co[level]) {
      areas.push(`<b>${co[level]}</b>`)
    }
  })

  if (co.verbatimLocality) {
    areas.push(co.verbatimLocality)
  }

  return areas.join('; ')
}

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
