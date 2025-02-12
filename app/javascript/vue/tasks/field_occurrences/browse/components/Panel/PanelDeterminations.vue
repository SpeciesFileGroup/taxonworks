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
import useStore from '../../store/determinations.js'
import PanelContainer from './PanelContainer.vue'
import TableData from '@/tasks/collection_objects/browse/components/Table/TableData.vue'

const HEADERS = ['OTU', 'Determiners', 'Date']

const store = useStore()

const list = computed(() =>
  store.determinations.map((d) => ({
    otu: d.otu.object_tag,
    roles: d?.determiner_roles?.map((r) => r?.person?.cached).join('; '),
    date: [d.day_made, d.month_made, d.year_made].filter(Boolean).join('/')
  }))
)
</script>
