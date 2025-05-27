<template>
  <SectionPanel
    :status="status"
    :name="title"
    :title="`${title} ${pagination ? '(' + pagination.total + ')' : ''}`"
  >
    <VSpinner v-if="isLoading" />
    <div
      v-if="list.length"
      class="separate-top"
    >
      <a :href="`${RouteNames.FilterCollectionObjects}?otu_id[]=${otu.id}`"
        >Open filter</a
      >
      <VPagination
        v-if="pagination"
        class="margin-small-top margin-small-bottom"
        :pagination="pagination"
        @next-page="(e) => loadCollectionObjects(e.page)"
      />
      <table class="full_width">
        <thead>
          <tr>
            <th class="w-2" />
            <th
              v-for="attr in DWC_ATTRIBUTES"
              :key="attr"
              v-text="attr"
            />
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
          </tr>
        </tbody>
      </table>
    </div>
  </SectionPanel>
</template>

<script setup>
import { CollectionObject, Citation } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'
import { getPagination } from '@/helpers'
import { COLLECTION_OBJECT } from '@/constants'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import SectionPanel from './shared/sectionPanel'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VPagination from '@/components/pagination.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

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
  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: undefined
  },

  otu: {
    type: Object,
    required: true
  }
})

const list = ref([])
const pagination = ref()
const isLoading = ref(false)

async function listParser(list) {
  const citations = (
    await Citation.where({
      citation_object_id: list.map((item) => item.id),
      citation_object_type: [COLLECTION_OBJECT]
    })
  ).body

  const getCitations = (citations, objectId) => {
    const items = citations.filter(
      (item) => item.citation_object_id === objectId
    )

    return items.map((item) => item.citation_source_body).join('; ')
  }

  return list.map((item) => ({
    id: item.id,
    globalId: item.global_id,
    ...item.dwc_occurrence,
    repository: item.repository?.object_label,
    citation: getCitations(citations, item.id)
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
