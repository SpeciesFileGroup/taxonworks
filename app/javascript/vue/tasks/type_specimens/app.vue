<template>
  <div id="vue_type_specimens">
    <VSpinner
      v-if="settings.isLoading || settings.isSaving"
      full-screen
      :legend="settings.isLoading ? 'Loading...' : 'Saving...'"
      :logo-size="{ width: '100px', height: '100px' }"
    />

    <div class="align-start gap-medium">
      <div class="cleft flex-col gap-medium">
        <PanelTaxonName v-if="!store.taxonName" />
        <template v-else>
          <MetadataSection />
          <PanelCollectionObject />
        </template>
      </div>
      <div
        v-if="store.taxonName"
        class="cright"
      >
        <div class="full_width">
          <TypeBox class="separate-bottom" />
          <SoftValidation :validations="validationStore.softValidations" />
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
import PanelTaxonName from './components/PanelTaxonName.vue'
import PanelCollectionObject from './components/PanelCollectionObject.vue'
import MetadataSection from './components/PanelMetadata.vue'
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
  width: 1240px;
  max-width: 1240px;
  margin-top: 1rem;

  .cright {
    width: 420px;
    min-width: 420px;
  }

  .cleft {
    width: 100%;
  }
}
</style>
