<template>
  <NavBar navbar-class="panel content relative rounded-tl-none rounded-tr-none">
    <div class="flex-separate gap-small">
      <div class="horizontal-left-content middle gap-medium">
        <AutocompletePopover
          url="/taxon_names/autocomplete"
          ref="autocomplete"
          panel-width="350px"
          title="Search a taxon name"
          placeholder="Search a taxon name..."
          param="term"
          display="label"
          label="label_html"
          :add-params="{ 'type[]': 'Protonym' }"
          medium
          variant="tonal"
          clear-after
          @select="loadTaxon"
        />
        <ul class="no_bullets context-menu text-xs">
          <template
            v-for="({ title, isAvailableFor }, index) in SectionComponents"
            :key="title"
          >
            <li v-if="isAvailableFor(taxon)">
              <a
                data-turbolinks="false"
                :class="{ active: activePosition == index }"
                @click.prevent="onNavClick(index)"
                >{{ getTitle(title) }}
              </a>
            </li>
          </template>
        </ul>
      </div>
      <div class="horizontal-center-content gap-small">
        <SaveTaxonName />
        <CloneTaxonName v-help.section.navbar.clone />
        <VBtn
          medium
          icon
          color="primary"
          variant="tonal"
          :disabled="!taxon.id"
          title="Create a child of this taxon name"
          v-help.section.navbar.sisterIcon
          @click="createNew(taxon.id)"
        >
          <IconAddChildrenNode class="w-4 h-4" />
        </VBtn>
        <VBtn
          icon
          medium
          color="primary"
          variant="tonal"
          :disabled="!parentId"
          title="Create a new taxon name with the same parent"
          v-help.section.navbar.childIcon
          @click="createNew(parentId)"
        >
          <IconAddSiblingNode class="w-4 h-4" />
        </VBtn>
        <CreateNewButton />
        <TaskSettings />
      </div>
    </div>
    <Autosave
      style="bottom: 0px; left: 0px"
      class="position-absolute full_width"
      :disabled="!taxon.id || !isAutosaveActive"
    />
  </NavBar>
</template>
<script setup>
import { SectionComponents } from '../const/components'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { computed, ref, useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import { useHotkey } from '@/composables'
import SaveTaxonName from './saveTaxonName.vue'
import CreateNewButton from './createNewButton.vue'
import CloneTaxonName from './cloneTaxon.vue'
import NavBar from '@/components/layout/NavBar'
import Autosave from './autosave'
import TaskSettings from './TaskSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'
import IconAddSiblingNode from '@/components/Icon/IconAddSiblingNode.vue'
import IconAddChildrenNode from '@/components/Icon/IconAddChildrenNode.vue'
import platformKey from '@/helpers/getPlatformKey'

const emit = defineEmits(['section-clicked'])
const store = useStore()
const unsavedChanges = computed(() => {
  return (
    store.getters[GetterNames.GetLastChange] >
    store.getters[GetterNames.GetLastSave]
  )
})

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const parent = computed(() => store.getters[GetterNames.GetParent])

const isAutosaveActive = computed(() => store.getters[GetterNames.GetAutosave])
const parentId = computed(() => parent.value?.id)
const activePosition = ref(0)
const autocompleteRef = useTemplateRef('autocomplete')

const shortcuts = ref([
  {
    keys: [platformKey(), 'f'],
    preventDefault: true,
    handler() {
      console.log('Entra')
      autocompleteRef.value?.toggle()
    }
  }
])

useHotkey(shortcuts.value)

function onNavClick(index) {
  activePosition.value = index
  emit('section-clicked', index)
}

function createNew(id) {
  navigateTo(
    `${RouteNames.NewTaxonName}?parent_id=${id}`,
    'You have unsaved changes. Are you sure you want to create a new taxon name? All unsaved changes will be lost.'
  )
}

function loadTaxon(taxonName) {
  navigateTo(
    `${RouteNames.NewTaxonName}?taxon_name_id=${taxonName.id}`,
    'You have unsaved changes. Are you sure you want to load another taxon name? All unsaved changes will be lost.'
  )
}

function navigateTo(url, confirmationMessage) {
  if (unsavedChanges.value && !window.confirm(confirmationMessage)) {
    return
  }

  window.open(url, '_self')
}

function getTitle(title) {
  return typeof title === 'function'
    ? title({ code: store.getters[GetterNames.GetNomenclaturalCode] })
    : title
}
</script>

<style lang="scss" scoped>
.button-new-icon {
  min-width: 28px;
  max-width: 28px;
  background-position: center;
  background-repeat: no-repeat;
}

.taxonname {
  font-weight: 300;
}

.context-menu a {
  cursor: pointer;
}

.unsaved li {
  a:first-child {
    padding-left: 0px;
  }
}
</style>
