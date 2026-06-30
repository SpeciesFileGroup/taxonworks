<template>
  <NavBar navbar-class="panel content relative">
    <div class="flex-separate gap-small">
      <ul class="no_bullets context-menu">
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
      <div class="horizontal-center-content gap-small">
        <TaskSettings />
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
        <CloneTaxonName v-help.section.navbar.clone />
        <SaveTaxonName />
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
import SaveTaxonName from './saveTaxonName.vue'
import CreateNewButton from './createNewButton.vue'
import CloneTaxonName from './cloneTaxon'
import NavBar from '@/components/layout/NavBar'
import Autosave from './autosave'
import TaskSettings from './TaskSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { SectionComponents } from '../const/components'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import IconAddSiblingNode from '@/components/Icon/IconAddSiblingNode.vue'
import IconAddChildrenNode from '@/components/Icon/IconAddChildrenNode.vue'

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

function onNavClick(index) {
  activePosition.value = index
  emit('section-clicked', index)
}

function createNew(id) {
  const url = `${RouteNames.NewTaxonName}?parent_id=${id}`

  if (unsavedChanges.value) {
    if (
      window.confirm(
        'You have unsaved changes. Are you sure you want to create a new taxon name? All unsaved changes will be lost.'
      )
    ) {
      window.open(url, '_self')
    }
  } else {
    window.open(url, '_self')
  }
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
