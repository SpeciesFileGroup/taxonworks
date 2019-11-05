<template>
  <div>
    <h1>New source</h1>
    <div class="flex-separate separate-bottom">
      <source-type/>
      <div>
        <button
          @click="saveSource"
          class="button normal-input button-submit button-size separate-right"
          type="button">
          Save
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
  </div>
</template>

<script>

import SourceType from './components/sourceType'

import Verbatim from './components/verbatim/main'
import Bibtex from './components/bibtex/main'
import Human from './components/person/main'

import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    SourceType,
    Verbatim,
    Bibtex,
    Human
  },
  computed: {
    section() {
      const type = this.$store.getters[GetterNames.GetType]
      return type ? type.split('::')[1] : undefined
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const sourceId = urlParams.get('source_id')

    if (/^\d+$/.test(sourceId)) {
      this.$store.dispatch(ActionNames.LoadSource, sourceId)
    }
  },
  methods: {
    reset () {
      this.$store.dispatch(ActionNames.ResetSource)
    },
    saveSource () {
      this.$store.dispatch(ActionNames.SaveSource)
    }
  }
}
</script>
<style scoped>
  .button-size {
    width: 140px;
  }
</style>