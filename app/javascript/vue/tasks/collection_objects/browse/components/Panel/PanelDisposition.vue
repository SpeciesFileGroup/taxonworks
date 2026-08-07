<template>
  <PanelContainer title="Disposition">
    <TableAttributes
      :header="['Location', 'Value']"
      :items="attributes"
    />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const container = computed(() => store.getters[GetterNames.GetContainer])
const currentRepository = computed(() => store.getters[GetterNames.GetCurrentRepository])
const repository = computed(() => store.getters[GetterNames.GetRepository])

const attributes = computed(() => ({
  Repository: repository.value.object_tag,
  'Current repository': currentRepository.value.object_tag,
  Container: container.value.object_tag
}))
</script>
