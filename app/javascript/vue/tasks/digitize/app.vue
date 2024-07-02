<template>
  <div id="vue-all-in-one">
    <div class="flex-separate middle">
      <h1>Comprehensive specimen digitization</h1>
      <ul class="context-menu">
        <li>
          <SettingsCollectionObject />
        </li>
        <li>
          <label v-help.sections.global.reorderFields>
            <input
              type="checkbox"
              v-model="settings.sortable"
            />
            Reorder fields
          </label>
        </li>
      </ul>
    </div>
    <spinner-component
      v-if="saving || loading"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      :legend="saving ? 'Saving changes...' : 'Loading...'"
    />
    <task-header />
    <collection-object class="separate-bottom" />
    <div class="horizontal-left-content align-start separate-top main-panel">
      <LeftColumn
        class="separate-right left-section"
        :disabled="!settings.sortable"
      />
      <collecting-event-layout class="separate-left item ce-section" />
    </div>
  </div>
</template>

<script setup>
import TaskHeader from './components/taskHeader/main.vue'
import CollectionObject from './components/collectionObject/main.vue'
import CollectingEventLayout from './components/collectingEvent/main.vue'
import SettingsCollectionObject from './components/settings/SettingCollectionObject.vue'
import SpinnerComponent from '@/components/ui/VSpinner.vue'
import platformKey from '@/helpers/getPlatformKey.js'
import useHotkey from 'vue3-hotkey'
import LeftColumn from './components/LeftColumn.vue'
import { User, Project } from '@/routes/endpoints'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'
import { GetterNames } from './store/getters/getters.js'
import { useStore } from 'vuex'
import { computed, ref, onMounted } from 'vue'

defineOptions({
  name: 'ComprehensiveSpecimenDigitization'
})

const store = useStore()

const saving = computed(() => store.getters[GetterNames.IsSaving])
const loading = computed(() => store.getters[GetterNames.IsLoading])
const settings = computed({
  get() {
    return store.getters[GetterNames.GetSettings]
  },
  set(value) {
    store.commit(MutationNames.SetSettings, value)
  }
})

const shortcuts = ref([
  {
    keys: [platformKey(), 'l'],
    handler() {
      setLockAll()
    }
  }
])

useHotkey(shortcuts.value)

onMounted(() => {
  const coId = location.pathname.split('/')[4]
  const urlParams = new URLSearchParams(window.location.search)
  const coIdParam = urlParams.get('collection_object_id')
  const ceIdParam = urlParams.get('collecting_event_id')

  addShortcutsDescription()

  User.preferences().then(({ body }) => {
    store.commit(MutationNames.SetPreferences, body)
  })

  Project.preferences().then(({ body }) => {
    store.commit(MutationNames.SetProjectPreferences, body)
  })

  if (!coIdParam) {
    store.dispatch(ActionNames.CreateDeterminationFromParams)
  }

  if (/^\d+$/.test(coId)) {
    store.dispatch(ActionNames.LoadDigitalization, coId)
  } else if (/^\d+$/.test(coIdParam)) {
    store.dispatch(ActionNames.LoadDigitalization, coIdParam)
  } else if (/^\d+$/.test(ceIdParam)) {
    store.dispatch(ActionNames.GetCollectingEvent, ceIdParam)
  }
})

function addShortcutsDescription() {
  const TASK = 'Comprehensive digitization task'
  const key = platformKey()

  TW.workbench.keyboard.createLegend(`${key}+s`, 'Save', TASK)
  TW.workbench.keyboard.createLegend(`${key}+n`, 'Save and new', TASK)
  TW.workbench.keyboard.createLegend(`${key}+p`, 'Add to container', TASK)
  TW.workbench.keyboard.createLegend(`${key}+l`, 'Lock/Unlock all', TASK)
  TW.workbench.keyboard.createLegend(`${key}+r`, 'Reset all', TASK)
  TW.workbench.keyboard.createLegend(
    `${key}+e`,
    'Browse collection object',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${key}+t`,
    'Go to new taxon name task',
    TASK
  )
  TW.workbench.keyboard.createLegend(`${key}+o`, 'Go to browse OTU', TASK)
  TW.workbench.keyboard.createLegend(
    `${key}+m`,
    'Go to new type material',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${key}+b`,
    'Go to browse nomenclature',
    TASK
  )
}

function setLockAll() {
  store.commit(MutationNames.LockAll)
}
</script>
<style lang="scss">
#vue-all-in-one {
  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
  .main-panel {
    display: flex;
  }
  .left-section {
    max-width: 25%;
    min-width: 420px;
  }
  .ce-section {
    display: flex;
    flex-grow: 2;
  }

  .otu_tag_taxon_name {
    white-space: pre-wrap !important;
  }

  textarea {
    resize: vertical;
  }
}
</style>
