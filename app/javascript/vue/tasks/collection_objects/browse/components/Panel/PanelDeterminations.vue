<template>
  <PanelContainer title="Determinations">
    <TableData
      :headers="HEADERS"
      :items="list"
    />
    <RadialFilterAttribute :parameters="parameters" />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import RadialFilterAttribute from 'components/radials/filter/RadialFilterAttribute.vue'
import TableData from '../Table/TableData.vue'

const HEADERS = ['OTU', 'Determiners', 'Data']

const store = useStore()
const determinations = computed(() => store.getters[GetterNames.GetDeterminations])

const parameters = computed(() => {
  const d = determinations.value[0]

  return d
    ? {
        otu_ids: [d.otu_id],
        ancestor_id: d.otu.taxon_name_id
      }
    : {}
})

const list = computed(() => {
  return determinations.value.map(d => ({
    otu: d.otu.object_tag,
    roles: d.determiner_roles.map(r => r?.person?.cached).join('; '),
    date: [d.day_made, d.month_made, d.year_made].filter(Boolean).join('/')
  }))
})
</script>
