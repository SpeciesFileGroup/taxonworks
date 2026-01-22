<template>
  <div
    id="vue_type_specimens"
    class="margin-medium-top"
  >
    <VSpinner
      v-if="settings.isLoading || settings.isSaving"
      full-screen
      :legend="settings.isLoading ? 'Loading...' : 'Saving...'"
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <div>
      <div class="align-start gap-medium">
        <div class="full_width flex-col gap-medium">
          <NameSection v-if="!store.taxonName" />
          <MetadataSection v-else />
          <TypeMaterialSection />
        </div>
        <div
          v-if="store.taxonName"
          class="cright item"
        >
          <div id="cright-panel">
            <TypeBox class="separate-bottom" />
            <SoftValidation :validations="validationStore.softValidations" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { setParam } from '@/helpers'
import { useHotkey } from '@/composables'
import { RouteNames } from '@/routes/routes'
import { ref, onMounted, watch } from 'vue'
import { URLParamsToJSON } from '@/helpers'

import SoftValidation from '@/components/soft_validations/panel.vue'
import NameSection from './components/nameSection.vue'
import TypeMaterialSection from './components/typeMaterial.vue'
import MetadataSection from './components/metadataSection.vue'
import TypeBox from './components/typeBox.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import useSoftvalidationStore from '@/components/Form/FormCollectingEvent/store/softValidations'
import useSettingStore from './store/settings.js'
import useStore from './store/store.js'

defineOptions({
  name: 'NewTypeMaterial'
})

const store = useStore()
const settings = useSettingStore()
const validationStore = useSoftvalidationStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 't'],
    preventDefault: true,
    handler() {
      switchToTask(RouteNames.NewTaxonName)
    }
  },
  {
    keys: [platformKey(), 'o'],
    preventDefault: true,
    handler() {
      switchToTask(RouteNames.BrowseOtu)
    }
  },
  {
    keys: [platformKey(), 'e'],
    preventDefault: true,
    handler() {
      switchToTask(RouteNames.DigitizeTask)
    }
  },
  {
    keys: [platformKey(), 'b'],
    preventDefault: true,
    handler() {
      switchToTask(RouteNames.BrowseNomenclature)
    }
  }
])

useHotkey(shortcuts.value)

onMounted(() => {
  const TASK = 'New type material'
  loadTaxonTypes()
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+t`,
    'Go to new taxon name task',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+o`,
    'Go to browse OTU',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+e`,
    'Go to comprehensive specimen digitization',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+b`,
    'Go to browse taxon names',
    TASK
  )
})

watch(
  () => store.taxonName?.id,
  (newVal) => {
    setParam(RouteNames.TypeMaterial, 'taxon_name_id', newVal)
  }
)

watch(
  () => store.typeMaterial.id,
  (newVal) => {
    setParam(RouteNames.TypeMaterial, 'type_material_id', newVal)
  }
)

async function loadTaxonTypes() {
  const params = URLParamsToJSON(window.location.href)
  const typeId = params.type_material_id
  const protonymId = params.protonym_id || params.taxon_name_id

  if (/^\d+$/.test(protonymId)) {
    settings.isLoading = true

    try {
      store.loadTaxonName(protonymId)
      await store.loadTypeMaterials(protonymId)

      if (typeId) {
        const item = store.typeMaterials.find((t) => t.id == typeId)

        if (item) {
          store.setTypeMaterial(item)
        }
      }
    } catch {
    } finally {
      settings.isLoading = false
    }
  }
}

function switchToTask(url) {
  if (store.taxonName.id) {
    window.open(`${url}?taxon_name_id=${store.taxonName.id}`, '_self')
  } else {
    window.open(url, '_self')
  }
}
</script>
<style lang="scss">
#vue_type_specimens {
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;
  width: 1240px;

  .cleft,
  .cright {
    min-width: 350px;
    max-width: 350px;
    width: 300px;
  }
  #cright-panel {
    width: 350px;
    max-width: 350px;
  }
  .cright-fixed-top {
    top: 68px;
    width: 1240px;
    z-index: 200;
    position: fixed;
  }
  .anchor {
    display: block;
    height: 65px;
    margin-top: -65px;
    visibility: hidden;
  }

  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
  .reload-app {
    cursor: pointer;
    &:hover {
      opacity: 0.8;
    }
  }
  .type-specimen-box {
    transition: all 1s;

    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    .header {
      border-left: 4px solid green;
      padding: 1em;
      padding-left: 1.5em;
      border-bottom: 1px solid var(--border-color);

      h3 {
        font-weight: 300;
      }
    }
    .body {
      padding: 2em;
      padding-top: 1em;
      padding-bottom: 1em;
    }
    .taxonName-input,
    #error_explanation {
      width: 300px;
    }
  }
}
</style>
