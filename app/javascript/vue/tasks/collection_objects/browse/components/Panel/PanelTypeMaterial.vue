<template>
  <PanelContainer title="Type materials">
    <ListITems
      :list="typeMaterials"
      label="object_tag"
      :remove="false"
    />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import ListITems from 'components/displayList.vue'

const store = useStore()
const typeMaterials = computed(() => store.getters[GetterNames.GetTypeMaterials])
</script>
