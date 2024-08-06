<template>
  <div id="taxonNameBox">
    <modal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Confirm delete</h3>
      </template>
      <template #body>
        <div>
          Are you sure you want to delete <span v-html="parent.object_tag" />
          {{ taxon.name }} ?
        </div>
      </template>
      <template #footer>
        <button
          @click="deleteTaxon()"
          type="button"
          class="normal-input button button-delete"
        >
          Delete
        </button>
      </template>
    </modal>
    <div class="panel">
      <div class="content">
        <div
          v-if="taxon.id"
          class="flex-separate middle"
        >
          <a
            :href="`/tasks/nomenclature/browse?taxon_name_id=${taxon.id}`"
            class="taxonname"
            v-html="taxonNameAndAuthor"
          />
          <div class="flex-wrap-column">
            <div class="horizontal-right-content gap-small">
              <RadialAnnotator :global-id="taxon.global_id" />
              <OtuRadial
                :object-id="taxon.id"
                :redirect="false"
              />
              <OtuRadial
                ref="otuRadialRef"
                :object-id="taxon.id"
                :taxon-name="taxon.object_tag"
              />
              <RadialObject :global-id="taxon.global_id" />
            </div>
            <div class="horizontal-right-content margin-small-top gap-small">
              <PinObject
                v-if="taxon.id"
                :object-id="taxon.id"
                type="TaxonName"
              />
              <DefaultConfidence :global-id="taxon.global_id" />
              <VBtn
                v-if="taxon.id"
                color="destroy"
                circle
                @click="isModalVisible = true"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </div>
        </div>
        <h3
          class="taxonname"
          v-else
        >
          New
        </h3>
      </div>
    </div>
  </div>
</template>

<script setup>
import OtuRadial from '@/components/otu/otu.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import DefaultConfidence from '@/components/ui/Button/ButtonConfidence.vue'
import PinObject from '@/components/ui/Button/ButtonPin.vue'
import Modal from '@/components/ui/Modal.vue'
import platformKey from '@/helpers/getPlatformKey'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useHotkey from 'vue3-hotkey'
import { TaxonName } from '@/routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { computed, ref, onBeforeMount } from 'vue'
import { useStore } from 'vuex'

const isModalVisible = ref(false)
const otuRadialRef = ref(null)
const store = useStore()
const shortcuts = ref([
  {
    keys: [platformKey(), 'b'],
    preventDefault: true,
    handler() {
      switchBrowse()
    }
  },
  {
    keys: [platformKey(), 'o'],
    preventDefault: true,
    handler() {
      switchBrowseOtu()
    }
  }
])

useHotkey(shortcuts.value)

const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const taxonNameAndAuthor = computed(
  () => `${taxon.value.cached_html} ${taxon.value.cached_author_year || ''}`
)

onBeforeMount(() => {
  TW.workbench.keyboard.createLegend(
    platformKey() + '+' + 'b',
    'Go to browse nomenclature',
    'New taxon name'
  )
  TW.workbench.keyboard.createLegend(
    platformKey() + '+' + 'o',
    'Go to browse otus',
    'New taxon name'
  )
})

function deleteTaxon() {
  TaxonName.destroy(taxon.value.id)
    .then(() => {
      reloadPage()
    })
    .catch(() => {})
}

function reloadPage() {
  window.location.href = '/tasks/nomenclature/new_taxon_name/'
}

function switchBrowse() {
  window.location.replace(
    `/tasks/nomenclature/browse?taxon_name_id=${taxon.value.id}`
  )
}

function switchBrowseOtu() {
  otuRadialRef.value.openApp()
}
</script>

<style lang="scss">
#taxonNameBox {
  .taxonname {
    font-size: 14px;
  }
}
</style>
