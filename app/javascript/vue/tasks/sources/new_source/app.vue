<template>
  <div>
    <h1>New source</h1>
    <div class="flex-separate separate-bottom">
      <source-type/>
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
    <component :is="section"/>
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

export default {
  components: {
    RadialAnnotator,
    PinComponent,
    SourceType,
    Verbatim,
    Bibtex,
    Human,
    CrossRef
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