<template>
  <div>
    <div class="flex-separate middle">
      <h1>New source</h1>
      <ul class="context-menu">
        <li>
          <autocomplete
            url="/sources/autocomplete"
            param="term"
            placeholder="Search a source..."
            label="label_html"
            clear-after
            @getItem="loadSource($event.id)"/>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable">
            Sortable fields
          </label>
        </li>
        <li>
          <a href="/tasks/sources/hub">Back to source hub</a>
        </li>
      </ul>
    </div>
    <nav-bar class="source-navbar">
      <div class="flex-separate full_width">
        <div class="middle">
          <span
            class="word_break"
            v-if="source.id"
            v-html="source.cached"/>
          <span v-else>New record</span>
          <template v-if="source.id">
            <pin-component
              class="margin-medium-left"
              :object-id="source.id"
              type="Source"/>
            <radial-annotator :global-id="source.global_id"/>
            <radial-object :global-id="source.global_id"/>
            <add-source
              :project-source-id="source.project_source_id"
              :id="source.id"/>
          </template>
        </div>
        <div
          class="horizontal-right-content"
          v-hotkey="shortcuts">
          <span
            v-if="unsave"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"/>
          <button
            @click="saveSource"
            :disabled="source.type === 'Source::Bibtex' && !source.bibtex_type"
            class="button normal-input button-submit button-size separate-right separate-left"
            type="button">
            Save
          </button>
          <button
            v-if="source.type === 'Source::Verbatim' && source.id"
            type="button"
            @click="convert">
            To BibTeX
          </button>
          <clone-source/>
          <button
            v-help.section.navBar.crossRef
            class="button normal-input button-default button-size separate-left"
            type="button"
            @click="showModal = true">
            CrossRef
          </button>
          <button
            class="button normal-input button-default button-size separate-left"
            type="button"
            @click="showBibtex = true">
            BibTeX
          </button>
          <button
            @click="showRecent = true"
            class="button normal-input button-default button-size separate-left"
            type="button">
            Recent
          </button>
          <button
            @click="reset"
            class="button normal-input button-default button-size separate-left"
            type="button">
            New
          </button>
        </div>
      </div>
    </nav-bar>
    <source-type class="margin-medium-bottom"/>
    <recent-component
      v-if="showRecent"
      @close="showRecent = false"/>
    <div class="horizontal-left-content align-start">
      <div class="full_width">
        <component :is="section"/>
      </div>
      <right-section class="margin-medium-left"/>
    </div>
    <cross-ref
      v-if="showModal"
      @close="showModal = false"/>
    <bibtex-button
      v-if="showBibtex"
      @close="showBibtex = false"/>
    <spinner-component
      v-if="settings.isConverting"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      legend="Converting verbatim to BiBTeX..."/>
  </div>
</template>

<script>

import SourceType from './components/sourceType'
import RecentComponent from './components/recent'
import SpinnerComponent from 'components/spinner'

import CrossRef from './components/crossRef'
import BibtexButton from './components/bibtex'
import Verbatim from './components/verbatim/main'
import Bibtex from './components/bibtex/main'
import Human from './components/person/main'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import AddSource from 'components/addToProjectSource'
import Autocomplete from 'components/ui/Autocomplete'
import CloneSource from './components/cloneSource'

import PinComponent from 'components/ui/Pinboard/VPin.vue'

import { User } from 'routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'
import { MutationNames } from './store/mutations/mutations'

import RightSection from './components/rightSection'
import NavBar from 'components/layout/NavBar'
import platformKey from 'helpers/getMacKey'

export default {
  name: 'NewSource',

  components: {
    Autocomplete,
    CloneSource,
    RadialAnnotator,
    RadialObject,
    PinComponent,
    SourceType,
    Verbatim,
    Bibtex,
    Human,
    CrossRef,
    RightSection,
    BibtexButton,
    AddSource,
    NavBar,
    RecentComponent,
    SpinnerComponent
  },

  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+s`] = this.saveSource
      keys[`${platformKey()}+n`] = this.reset

      return keys
    },

    section () {
      const type = this.$store.getters[GetterNames.GetType]
      return type ? type.split('::')[1] : undefined
    },

    source () {
      return this.$store.getters[GetterNames.GetSource]
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },

    unsave() {
      const settings = this.$store.getters[GetterNames.GetSettings]
      return settings.lastSave < settings.lastEdit
    }
  },

  data () {
    return {
      showModal: false,
      showBibtex: false,
      showRecent: false
    }
  },

  watch: {
    source: {
      handler (newVal, oldVal) {
        if (newVal.id === oldVal.id) {
          this.settings.lastEdit = Date.now()
        }
      },
      deep: true
    }
  },

  mounted () {
    TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save', 'New source')
    TW.workbench.keyboard.createLegend(`${platformKey()}+n`, 'New', 'New source')
    TW.workbench.keyboard.createLegend(`${platformKey()}+c`, 'Clone source', 'New source')

    const urlParams = new URLSearchParams(window.location.search)
    const sourceId = urlParams.get('source_id')

    if (/^\d+$/.test(sourceId)) {
      this.$store.dispatch(ActionNames.LoadSource, sourceId)
    }

    User.preferences().then(response => {
      this.$store.commit(MutationNames.SetPreferences, response.body)
    })
  },

  methods: {
    reset () {
      this.$store.dispatch(ActionNames.ResetSource)
    },
    saveSource () {
      if (this.source.type === 'Source::Bibtex' && !this.source.bibtex_type) return
      this.$store.dispatch(ActionNames.SaveSource)
    },
    cloneSource () {
      this.$store.dispatch(ActionNames.CloneSource)
    },
    convert () {
      this.$store.dispatch(ActionNames.ConvertToBibtex)
    },
    loadSource (sourceId) {
      this.$store.dispatch(ActionNames.LoadSource, sourceId)
    }
  }
}
</script>
<style scoped>
  .button-size {
    width: 100px;
  }
</style>
