<template>
  <div id="vue_type_specimens">
    <VSpinner
      v-if="settings.loading || settings.saving"
      full-screen
      :legend="settings.loading ? 'Loading...' : 'Saving...'"
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <div class="flex-separate middle">
      <h1>{{ isNew }} type specimen</h1>
      <VBtn
        circle
        color="primary"
        @click="reloadApp"
      >
        <VIcon
          name="reset"
          x-small
        />
      </VBtn>
    </div>
    <div>
      <div class="align-start gap-medium">
        <div class="full_width">
          <NameSection
            class="separate-bottom"
            v-if="!taxon"
          />
          <MetadataSection
            v-if="taxon"
            class="separate-bottom"
          />
          <TypeMaterialSection class="separate-bottom" />
        </div>
        <div
          v-if="taxon"
          class="cright item"
        >
          <div id="cright-panel">
            <TypeBox class="separate-bottom" />
            <SoftValidation :validations="softValidations" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import SoftValidation from '@/components/soft_validations/panel.vue'
import NameSection from './components/nameSection.vue'
import TypeMaterialSection from './components/typeMaterial.vue'
import MetadataSection from './components/metadataSection.vue'
import TypeBox from './components/typeBox.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import setParamsId from '@/helpers/setParam.js'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { useHotkey } from '@/composables'
import ActionNames from './store/actions/actionNames'
import { GetterNames } from './store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { computed, ref, onMounted, watch } from 'vue'
import { useStore } from 'vuex'

defineOptions({
  name: 'NewTypeMaterial'
})

const store = useStore()

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const settings = computed(() => store.getters[GetterNames.GetSettings])
const softValidations = computed(
  () => store.getters[GetterNames.GetSoftValidation]
)
const isNew = computed(() =>
  store.getters[GetterNames.GetTypeMaterial].id ? 'Edit' : 'New'
)

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
    'Go to browse nomenclature',
    TASK
  )
})

watch(taxon, (newVal) => {
  if (newVal?.id) {
    setParamsId(RouteNames.TypeMaterial, 'taxon_name_id', newVal.id)
  }
})

function reloadApp() {
  window.location.href = '/tasks/type_material/edit_type_material'
}

function loadTaxonTypes() {
  const params = new URLSearchParams(window.location.search)
  const typeId = params.get('type_material_id')
  const protonymId = params.get('protonym_id') || params.get('taxon_name_id')

  if (/^\d+$/.test(protonymId)) {
    store.dispatch(ActionNames.LoadTaxonName, protonymId).then(() => {
      store
        .dispatch(ActionNames.LoadTypeMaterials, protonymId)
        .then((response) => {
          if (/^\d+$/.test(typeId)) {
            loadType(response, typeId)
          }
        })
    })
  }
}

function loadType(list, typeId) {
  const findType = list.find((type) => type.id === Number(typeId))

  if (findType) {
    store.dispatch(ActionNames.LoadTypeMaterial, findType)
  }
}

function switchToTask(url) {
  if (taxon.value.id) {
    window.open(`${url}?taxon_name_id=${taxon.value.id}`, '_self')
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
      border-bottom: 1px solid #f5f5f5;

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
