<template>
  <div>
    <div class="flex-separate middle">
    <h1>New source</h1>
    <a href="/tasks/sources/hub">Back to source hub</a>
    </div>
    <div class="flex-separate separate-bottom">
      <source-type/>
      <div>
        <span
          v-if="source.id"
          v-html="source.cached"/>
        <span v-else>New record</span>
      </div>
      <div class="horizontal-right-content">
        <pin-component
          v-if="source.id"
          :object-id="source.id"
          type="Source"/>
        <radial-annotator
          v-if="source.id"
          :global-id="source.global_id"/>
        <button
          @click="saveSource"
          class="button normal-input button-submit button-size separate-right separate-left"
          type="button">
          Save
        </button>
        <button
          :disabled="!source.id"
          @click="cloneSource"
          class="button normal-input button-submit button-size"
          type="button">
          Clone
        </button>
        <button
          class="button normal-input button-default button-size separate-left"
          type="button"
          @click="showModal = true">
          CrossRef
        </button>
        <button
          @click="reset"
          class="button normal-input button-default button-size separate-left"
          type="button">
          New
        </button>
      </div>
    </div>
    <div class="horizontal-left-content align-start">
      <component class="full_width" :is="section"/>
      <right-section class="separate-left"/>
    </div>
    <cross-ref
      v-if="showModal"
      @close="showModal = false"/>
  </div>
</template>

<script>

import SourceType from './components/sourceType'

import CrossRef from './components/crossRef'
import Verbatim from './components/verbatim/main'
import Bibtex from './components/bibtex/main'
import Human from './components/person/main'
import RadialAnnotator from 'components/annotator/annotator'

import PinComponent from 'components/pin'

import { GetUserPreferences } from './request/resources'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'
import { MutationNames } from './store/mutations/mutations'

import RightSection from './components/rightSection'

export default {
  components: {
    RadialAnnotator,
    PinComponent,
    SourceType,
    Verbatim,
    Bibtex,
    Human,
    CrossRef,
    RightSection
  },
  computed: {
    section () {
      const type = this.$store.getters[GetterNames.GetType]
      return type ? type.split('::')[1] : undefined
    },
    source () {
      return this.$store.getters[GetterNames.GetSource]
    }
  },
  data () {
    return {
      showModal: false
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const sourceId = urlParams.get('source_id')

    if (/^\d+$/.test(sourceId)) {
      this.$store.dispatch(ActionNames.LoadSource, sourceId)
    }

    GetUserPreferences().then(response => {
      this.$store.commit(MutationNames.SetPreferences, response.body)
    })
  },
  methods: {
    reset () {
      this.$store.dispatch(ActionNames.ResetSource)
    },
    saveSource () {
      this.$store.dispatch(ActionNames.SaveSource)
    },
    cloneSource () {
      this.$store.dispatch(ActionNames.CloneSource)
    }
  }
}
</script>
<style scoped>
  .button-size {
    width: 100px;
  }
</style>