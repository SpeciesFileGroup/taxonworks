<template>
  <div
    id="vue-all-in-one"
    v-shortkey="[getOSKey(), 'l']"
    @shortkey="setLockAll">
    <div class="flex-separate middle">
      <h1>Comprehensive specimen digitization</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable">
            Sortable fields
          </label>
        </li>
      </ul>
    </div>
    <spinner-component
      v-if="saving || loading"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      :legend="(saving ? 'Saving changes...' : 'Loading...')"/>
    <task-header/>
    <collection-object class="separate-bottom"/>
    <div class="horizontal-left-content align-start separate-top main-panel">
      <draggable
        class="separate-right left-section"
        v-model="componentsOrder"
        :disabled="!settings.sortable"
        @end="updatePreferences">
        <component
          class="margin-medium-bottom"
          v-for="componentName in componentsOrder"
          :key="componentName"
          :is="componentName"/>
      </draggable>
      <collection-event-layout class="separate-left item ce-section"/>
    </div>
  </div>
</template>

<script>
import TaskHeader from './components/taskHeader/main.vue'
import CollectionObject from './components/collectionObject/main.vue'
import TaxonDeterminationLayout from './components/taxonDetermination/main.vue'
import CollectionEventLayout from './components/collectionEvent/main.vue'
import TypeMaterial from './components/typeMaterial/typeMaterial.vue'
import BiologicalAssociation from './components/biologicalAssociation/main.vue'
import SortComponent from './components/shared/sortComponenets.vue'
import { User, Project } from 'routes/endpoints'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'
import { GetterNames } from './store/getters/getters.js'
import SpinnerComponent from 'components/spinner.vue'
import GetOSKey from 'helpers/getMacKey.js'
import Draggable from 'vuedraggable'

export default {
  mixins: [SortComponent],
  components: {
    TaskHeader,
    CollectionObject,
    TypeMaterial,
    TaxonDeterminationLayout,
    BiologicalAssociation,
    CollectionEventLayout,
    SpinnerComponent,
    Draggable
  },
  computed: {
    saving() {
      return this.$store.getters[GetterNames.IsSaving]
    },
    loading() {
      return this.$store.getters[GetterNames.IsLoading]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      componentsOrder: ['TaxonDeterminationLayout', 'BiologicalAssociation', 'TypeMaterial'],
      keyStorage: 'tasks::digitize::LeftColumnOrder'
    }
  },
  mounted() {
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

    if (/^\d+$/.test(coId)) {
      this.$store.dispatch(ActionNames.LoadDigitalization, coId)
    }
    else if (/^\d+$/.test(coIdParam)) {
      this.$store.dispatch(ActionNames.LoadDigitalization, coIdParam)
    } else if (/^\d+$/.test(ceIdParam)) {
      this.$store.dispatch(ActionNames.GetCollectionEvent, ceIdParam)
    }
  },
  methods: {
    addShortcutsDescription() {
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+s`, 'Save', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+n`, 'Save and new', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+p`, 'Add to container', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+l`, 'Lock/Unlock all', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+r`, 'Reset all', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+e`, 'Browse collection object', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+t`, 'Go to new taxon name task', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+o`, 'Go to browse OTU', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+m`, 'Go to new type material', 'Comprehensive digitization task')
      TW.workbench.keyboard.createLegend(`${this.getOSKey()}+b`, 'Go to browse nomenclature', 'Comprehensive digitization task')
    },
    getOSKey: GetOSKey,
    setLockAll() {
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
  }
</style>
