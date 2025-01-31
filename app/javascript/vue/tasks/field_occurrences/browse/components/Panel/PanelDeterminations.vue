<template>
  <PanelContainer title="Determinations">
    <TableData
      :headers="HEADERS"
      :items="list"
    />
  </PanelContainer>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { TaxonDetermination } from '@/routes/endpoints'
import PanelContainer from './PanelContainer.vue'
import TableData from '@/tasks/collection_objects/browse/components/Table/TableData.vue'

const HEADERS = ['OTU', 'Determiners', 'Date']

const props = defineProps({
  objectId: {
    type: [String, undefined],
    required: true
  },

  objectType: {
    type: [String, undefined],
    required: true
  }
})

const determinations = ref([])

watch(
  () => props.objectId,
  (id) => {
    determinations.value = []

    if (id) {
      TaxonDetermination.where({
        taxon_determination_object_id: props.objectId,
        taxon_determination_object_type: props.objectType
      }).then(({ body }) => {
        determinations.value = body
      })
    }
  }
)

const list = computed(() =>
  determinations.value.map((d) => ({
    otu: d.otu.object_tag,
    roles: d?.determiner_roles?.map((r) => r?.person?.cached).join('; '),
    date: [d.day_made, d.month_made, d.year_made].filter(Boolean).join('/')
  }))
)
</script>
