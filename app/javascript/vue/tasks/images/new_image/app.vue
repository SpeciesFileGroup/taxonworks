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
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="store.dispatch(ActionNames.ResetStore)"
        >Reset
      </span>
    </div>
    <ImageDropzone
      v-model="images"
      @delete="removeImage"
      @on-clear="clearDataCreated"
    />

    <ApplyAttributes class="margin-medium-bottom margin-medium-top" />
    <TableGrid
      class="gap-medium margin-medium-bottom"
      :columns="3"
      :column-width="{
        default: '1fr'
      }"
    >
      <component
        v-for="componentName in PANEL_NAME"
        :key="componentName"
        :is="PANEL_COMPONENTS[componentName]"
      />
    </TableGrid>
    <PanelSqed />
  </div>
</template>

<script setup>
import SpinnerComponent from '@/components/spinner'
import ImageDropzone from './components/images/imageDropzone'
import ApplyAttributes from './components/ApplyAttributes'

import PanelSqed from './components/Panel/PanelSqed/PanelSqed.vue'

import TableGrid from '@/components/layout/Table/TableGrid.vue'
import { PANEL_COMPONENTS, PANEL_NAME } from './const/layout'
import { GetterNames } from './store/getters/getters.js'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'
import { useStore } from 'vuex'
import { computed } from 'vue'

const store = useStore()

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
