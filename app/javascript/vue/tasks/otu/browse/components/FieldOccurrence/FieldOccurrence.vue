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
      <a :href="`${RouteNames.FilterFieldOccurrence}?otu_id[]=${otu.id}`"
        >Open filter</a
      >
      <VPagination
        v-if="pagination"
        class="margin-small-top margin-small-bottom"
        :pagination="pagination"
        @next-page="(e) => loadFieldOccurrences(e.page)"
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
              <ModalDepictions :depictions="item.depictions" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </SectionPanel>
</template>

<script setup>
import { FieldOccurrence, Citation, Depiction } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'
import { getPagination } from '@/helpers'
import { FIELD_OCCURRENCE } from '@/constants'
import SectionPanel from '../shared/sectionPanel'
import ModalDepictions from '../shared/ModalDepictions.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
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
      citation_object_type: [FIELD_OCCURRENCE]
    })
  ).body

  const depictions = (
    await Depiction.where({
      depiction_object_id: list.map((item) => item.id),
      depiction_object_type: FIELD_OCCURRENCE
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
    citation: getCitations(citations, item.id),
    depictions: depictions.filter((d) => d.depiction_object_id === item.id)
  }))
}

function loadFieldOccurrences(page = 1) {
  isLoading.value = true
  FieldOccurrence.filter({
    otu_id: [props.otu.id],
    page,
    per: 50,
    extend: ['dwc_occurrence']
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
      loadFieldOccurrences()
    }
  },
  { immediate: true }
)
</script>
