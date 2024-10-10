<template>
  <NavBar navbar-class="panel content relative">
    <div class="flex-separate">
      <ul class="no_bullets context-menu">
        <template
          v-for="({ title, isAvailableFor }, index) in SectionComponents"
          :key="title"
        >
          <li
            class="navigation-item context-menu-option"
            v-if="isAvailableFor(taxon)"
          >
            <a
              data-turbolinks="false"
              :class="{ active: activePosition == index }"
              :href="'#' + getTitle(title).toLowerCase().replace(' ', '-')"
              @click="activePosition = index"
              >{{ getTitle(title) }}
            </a>
          </li>
        </template>
      </ul>
      <div class="horizontal-center-content margin-medium-left">
        <SaveTaxonName
          class="normal-input button button-submit separate-right"
        />
        <CloneTaxonName
          v-help.section.navbar.clone
          class="separate-right"
        />
        <button
          type="button"
          title="Create a child of this taxon name"
          v-help.section.navbar.sisterIcon
          @click="createNew(taxon.id)"
          :disabled="!taxon.id"
          class="button normal-input button-default btn-create-child button-new-icon margin-small-right"
        />
        <button
          type="button"
          @click="createNew(parentId)"
          :disabled="!parentId"
          title="Create a new taxon name with the same parent"
          v-help.section.navbar.childIcon
          class="button normal-input button-default btn-create-sister button-new-icon margin-small-right"
        />
        <CreateNewButton />
      </div>
    </div>
    <autosave
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
import { SectionComponents } from '../const/components'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'

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
:deep(button) {
  min-width: 80px;
  width: 100%;
}

.button-new-icon {
  min-width: 28px;
  max-width: 28px;
  background-position: center;
  background-repeat: no-repeat;
}

.taxonname {
  font-weight: 300;
}
.unsaved li {
  a {
    font-size: 13px;
  }
  a:first-child {
    padding-left: 0px;
  }
}
</style>
