<template>
  <PanelContainer title="Determinations">
    <ListITems
      class="no_bullets"
      :list="determinations"
      label="object_tag"
      :remove="false"
    />
    <RadialFilterAttribute :parameters="parameters" />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import ListITems from 'components/displayList.vue'
import RadialFilterAttribute from 'components/radials/filter/RadialFilterAttribute.vue'

const store = useStore()
const determinations = computed(() => store.getters[GetterNames.GetDeterminations])

const parameters = computed(() => {
  const d = determinations.value[0]

  return d
    ? {
        otu_ids: [d.otu_id],
        taxon_name_id: d.otu.taxon_name_id
      }
    : {}
})
</script>
