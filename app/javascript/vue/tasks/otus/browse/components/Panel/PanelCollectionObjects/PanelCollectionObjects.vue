<template>
  <PanelLayout
    :status="status"
    :name="title"
    :title="`${title} ${pagination ? '(' + pagination.total + ')' : ''}`"
    :spinner="isLoading"
  >
    <div
      v-if="list.length"
      class="separate-top"
    >
      <a :href="`${RouteNames.FilterCollectionObjects}?otu_id[]=${otu.id}`">
        Open filter
      </a>
      <VPagination
        v-if="pagination"
        class="margin-small-top margin-small-bottom"
        :pagination="pagination"
        @next-page="(e) => loadCollectionObjects(e.page)"
      />
      <table class="full_width table-striped">
        <thead>
          <tr>
            <th class="w-2" />
            <th
              v-for="attr in DWC_ATTRIBUTES"
              :key="attr"
              v-text="attr"
            />
            <th>Depictions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
          >
            <td>
              <div class="horizontal-left-content middle gap-small">
                <RadialAnnotator :global-id="item.globalId" />
                <RadialObject :global-id="item.globalId" />
                <RadialNavigator :global-id="item.globalId" />
              </div>
            </td>
            <td
              v-for="attr in DWC_ATTRIBUTES"
              :key="attr"
              v-text="item[attr]"
            />
            <td>
              <PanelCollectionObjectsDepictions :depictions="item.depictions" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else>No specimen records available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { CollectionObject, Citation, Depiction } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { getPagination } from '@/helpers'
import { COLLECTION_OBJECT } from '@/constants'
import PanelLayout from '../PanelLayout.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VPagination from '@/components/pagination.vue'
import PanelCollectionObjectsDepictions from './PanelCollectionObjectsDepictions.vue'

const DWC_ATTRIBUTES = [
  'catalogNumber',
  'recordNumber',
  'otherCatalogNumbers',
  'individualCount',
  'country',
  'stateProvince',
  'verbatimLocality',
  'year',
  'typeStatus',
  'repository',
  'citation'
]

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Specimen records'
  }
})

const list = ref([])
const pagination = ref()
const isLoading = ref(false)

async function listParser(items) {
  const citations = (
    await Citation.where({
      citation_object_id: items.map((item) => item.id),
      citation_object_type: [COLLECTION_OBJECT]
    })
  ).body

  const getCitations = (citations, objectId) => {
    return citations
      .filter((item) => item.citation_object_id === objectId)
      .sort((a, b) => (b.is_original === true) - (a.is_original === true))
      .map((item) => item.citation_source_body)
      .join('; ')
  }

  const depictions = (
    await Depiction.where({
      depiction_object_id: items.map((item) => item.id),
      depiction_object_type: COLLECTION_OBJECT
    })
  ).body

  return items.map((item) => ({
    id: item.id,
    globalId: item.global_id,
    ...item.dwc_occurrence,
    repository: item.repository?.object_label,
    citation: getCitations(citations, item.id),
    depictions: depictions.filter((d) => d.depiction_object_id === item.id)
  }))
}

function loadCollectionObjects(page = 1) {
  isLoading.value = true
  CollectionObject.filter({
    otu_id: [props.otu.id],
    page,
    per: 50,
    extend: ['dwc_occurrence', 'repository']
  })
    .then(async (response) => {
      pagination.value = getPagination(response)
      list.value = await listParser(response.body)
    })
    .finally(() => (isLoading.value = false))
}

watch(
  () => props.otu?.id,
  (newVal) => {
    if (newVal) {
      loadCollectionObjects()
    }
  },
  { immediate: true }
)
</script>
