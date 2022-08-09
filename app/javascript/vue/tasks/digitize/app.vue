<template>
  <div
    id="vue-all-in-one"
    v-hotkey="shortcuts"
  >
    <div class="flex-separate middle">
      <h1>Comprehensive specimen digitization</h1>
      <ul class="context-menu">
        <li>
          <settings-collection-object />
        </li>
        <li>
          <label v-help.sections.global.reorderFields>
            <input
              type="checkbox"
              v-model="settings.sortable"
            >
            Reorder fields
          </label>
        </li>
      </ul>
    </div>
    <spinner-component
      v-if="saving || loading"
      full-screen
      :logo-size="{ width: '100px', height: '100px'}"
      :legend="(saving ? 'Saving changes...' : 'Loading...')"
    />
    <task-header />
    <collection-object class="separate-bottom" />
    <div class="horizontal-left-content align-start separate-top main-panel">
      <draggable
        class="separate-right left-section"
        v-model="componentsOrder"
        :disabled="!settings.sortable"
        :item-key="item => item"
        @end="updatePreferences"
      >
        <template #item="{ element }">
          <component
            class="margin-medium-bottom"
            :is="element"
          />
        </template>
      </draggable>
      <collecting-event-layout class="separate-left item ce-section" />
    </div>
  </div>
</template>

<script>
import TaskHeader from './components/taskHeader/main.vue'
import CollectionObject from './components/collectionObject/main.vue'
import TaxonDeterminationLayout from './components/taxonDetermination/main.vue'
import CollectingEventLayout from './components/collectingEvent/main.vue'
import TypeMaterial from './components/typeMaterial/TypeMaterialMain.vue'
import BiologicalAssociation from './components/biologicalAssociation/main.vue'
import SettingsCollectionObject from './components/settings/SettingCollectionObject.vue'
import SortComponent from './components/shared/sortComponenets.vue'
import { User, Project } from 'routes/endpoints'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'
import { GetterNames } from './store/getters/getters.js'
import SpinnerComponent from 'components/spinner.vue'
import platformKey from 'helpers/getPlatformKey.js'
import Draggable from 'vuedraggable'

export default {
  name: 'Comprehensive',

  mixins: [SortComponent],

  components: {
    TaskHeader,
    CollectionObject,
    TypeMaterial,
    TaxonDeterminationLayout,
    BiologicalAssociation,
    CollectingEventLayout,
    SpinnerComponent,
    Draggable,
    SettingsCollectionObject
  },

  computed: {
    saving () {
      return this.$store.getters[GetterNames.IsSaving]
    },
    loading () {
      return this.$store.getters[GetterNames.IsLoading]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+l`] = this.setLockAll

      return keys
    }
  },

  data () {
    return {
      keyStorage: 'tasks::digitize::LeftColumnOrder',
      componentsSection: 'leftColumn'
    }
  },

  mounted () {
    const coId = location.pathname.split('/')[4]
    const urlParams = new URLSearchParams(window.location.search)
    const coIdParam = urlParams.get('collection_object_id')
    const ceIdParam = urlParams.get('collecting_event_id')

    this.addShortcutsDescription()

    User.preferences().then(response => {
      this.$store.commit(MutationNames.SetPreferences, response.body)
    })

    Project.preferences().then(response => {
      this.$store.commit(MutationNames.SetProjectPreferences, response.body)
    })

    if (!coIdParam) {
      this.$store.dispatch(ActionNames.CreateDeterminationFromParams)
    }

    if (/^\d+$/.test(coId)) {
      this.$store.dispatch(ActionNames.LoadDigitalization, coId)
    } else if (/^\d+$/.test(coIdParam)) {
      this.$store.dispatch(ActionNames.LoadDigitalization, coIdParam)
    } else if (/^\d+$/.test(ceIdParam)) {
      this.$store.dispatch(ActionNames.GetCollectingEvent, ceIdParam)
    }
  },

  methods: {
    addShortcutsDescription () {
      TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+n`, 'Save and new', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+p`, 'Add to container', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+l`, 'Lock/Unlock all', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+r`, 'Reset all', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+e`, 'Browse collection object', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+t`, 'Go to new taxon name task', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+o`, 'Go to browse OTU', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+m`, 'Go to new type material', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${platformKey()}+b`, 'Go to browse nomenclature', 'Comprehensive digitization task')
    },

    setLockAll () {
      this.$store.commit(MutationNames.LockAll)
    }
  }
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
    .modal-container {
      width: 90vw;
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
  }
</style>
