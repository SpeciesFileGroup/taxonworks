<template>
  <div>
    <h1>New source</h1>
    <source-type/>
    <component :is="section"/>
  </div>
</template>

<script>

import SourceType from './components/sourceType'

import Verbatim from './components/verbatim/main'
import Bibtex from './components/bibtex/main'
import Human from './components/person/main'

import { GetterNames } from './store/getters/getters'

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
  }
}
</script>
