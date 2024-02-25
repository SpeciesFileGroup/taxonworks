<template>
  <div id="vue-task-images-new">
    <spinner-component
      :full-screen="true"
      :legend="'Saving...'"
      :logo-size="{ width: '100px', height: '100px' }"
      v-if="isSaving"
    />
    <div class="flex-separate middle">
      <h1>New image</h1>
      <div class="horizontal-left-content gap-small">
        <LayoutSettings
          v-model="layout"
          :list="Object.values(PANEL_NAME)"
        />
        <VBtn
          circle
          medium
          color="primary"
          @click="store.dispatch(ActionNames.ResetStore)"
        >
          <VIcon
            name="reset"
            x-small
          />
        </VBtn>
      </div>
    </div>
    <div class="flex-wrap-column gap-medium">
      <ImageDropzone
        v-model="images"
        @delete="removeImage"
        @on-clear="clearDataCreated"
      />

      <ApplyAttributes />
      <TableGrid
        v-if="layout.panels.length"
        class="gap-medium"
        :columns="3"
        :column-width="{
          default: '1fr'
        }"
      >
        <component
          v-for="componentName in layout.panels"
          :key="componentName"
          :is="PANEL_COMPONENTS[componentName]"
        />
      </TableGrid>
      <PanelSqed v-if="layout.isStagePanelVisible" />
    </div>
  </div>
</template>

<script setup>
import SpinnerComponent from '@/components/ui/VSpinner'
import ImageDropzone from './components/images/imageDropzone'
import ApplyAttributes from './components/ApplyAttributes'

import PanelSqed from './components/Panel/PanelSqed/PanelSqed.vue'
import LayoutSettings from './components/LayoutSettings.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { PANEL_COMPONENTS, PANEL_NAME } from './const/layout'
import { GetterNames } from './store/getters/getters.js'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'
import { useStore } from 'vuex'
import { computed, ref } from 'vue'

const store = useStore()
const layout = ref({
  panels: Object.values(PANEL_NAME),
  isStagePanelVisible: true
})

const images = computed({
  get: () => store.getters[GetterNames.GetImagesCreated],

  set(value) {
    store.commit(MutationNames.SetImagesCreated, value)
  }
})
const isSaving = computed(() => store.getters[GetterNames.GetSettings].saving)

function clearDataCreated() {
  store.commit(MutationNames.SetDepictions, [])
  store.commit(MutationNames.SetAttributionsCreated, [])
}
function removeImage(image) {
  store.dispatch(ActionNames.RemoveImage, image)
}
</script>

<style lang="scss">
#vue-task-images-new {
  .panel-section {
    flex-grow: 1;
    flex-shrink: 1;
    flex-basis: 0;
  }
}
</style>
