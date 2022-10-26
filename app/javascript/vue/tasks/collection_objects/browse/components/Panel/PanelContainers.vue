<template>
  <PanelContainer title="Container">
    <span v-html="container.object_tag" />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const container = computed(() => store.getters[GetterNames.GetContainer])
</script>
