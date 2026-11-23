<template>
  <div>
    <VSpinner
      v-if="store.isLoading"
      full-screen
      legend="Loading..."
    />
    <div class="flex-separate align-start gap-medium margin-medium-bottom">
      <div class="flex-col gap-small">
        <h1>Quick mobile material</h1>
        <h2 v-if="store.composition">{{ store.composition.name }}</h2>
        <CompositionPicker
          v-else
          @select="({ id }) => store.loadComposition(id)"
          @create="(name) => store.createComposition(name)"
        />
      </div>
      <TaskTokenPanel @select="({ id }) => store.loadComposition(id)" />
    </div>

    <SettingsPanel class="margin-medium-bottom" />

    <ItemsTable
      v-if="store.composition"
      :items="store.items"
    />
  </div>
</template>

<script setup>
import { onBeforeMount, watch } from 'vue'
import { setParam } from '@/helpers'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import { RouteNames } from '@/routes/routes'
import useStore from './store/store'
import VSpinner from '@/components/ui/VSpinner.vue'
import CompositionPicker from './components/CompositionPicker.vue'
import ItemsTable from './components/ItemsTable.vue'
import SettingsPanel from './components/SettingsPanel.vue'
import TaskTokenPanel from './components/TaskTokenPanel.vue'

const store = useStore()

watch(
  () => store.composition?.id,
  (id) => setParam(RouteNames.QuickMobileMaterial, 'composition_id', id)
)

onBeforeMount(async () => {
  await store.loadSettings()

  const { composition_id: compositionId } = useQueryParam().parameters

  if (compositionId) await store.loadComposition(compositionId).catch(() => {})
})
</script>
