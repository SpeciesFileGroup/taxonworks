<template>
  <block-layout
    anchor="author"
    v-help.section.author.container
    :spinner="!taxon.id"
  >
    <template #header>
      <h3>Author</h3>
    </template>
    <template #body>
      <switch-component
        class="margin-medium-bottom"
        :options="sections"
        use-index
        v-model="tabIndex"
      />
      <component :is="componentName"/>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import SwitchComponent from 'components/switch.vue'
import BlockLayout from 'components/layout/BlockLayout'
import AuthorPerson from './AuthorPeople.vue'
import AuthorSource from './AuthorSource.vue'
import AuthorVerbatim from './AuthorVerbatim.vue'

const TAB = {
  Source: 'Source',
  Verbatim: 'Verbatim',
  Person: 'Person'
}

function getTabLabel (label, hasData) {
  return label + (hasData ? ' ✓' : '')
}

function getTabIndex (tab) {
  return Object.values(TAB).findIndex(value => value === tab)
}

export default {
  components: {
    AuthorPerson,
    AuthorSource,
    AuthorVerbatim,
    BlockLayout,
    SwitchComponent
  },
  computed: {
    componentName () {
      const tab = Object.keys(TAB)[this.tabIndex]
      return `Author${tab}`
    },

    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    verbatimFieldsWithData () {
      return this.taxon.verbatim_author || this.taxon.year_of_publication
    },

    hasRoles () {
      return this.$store.getters[GetterNames.GetRoles].length
    },

    sections () {
      return [
        getTabLabel(TAB.Source,this.citation),
        getTabLabel(TAB.Verbatim, this.verbatimFieldsWithData),
        getTabLabel(TAB.Person, this.hasRoles)
      ]
    }
  },

  data () {
    return {
      tabIndex: 0
    }
  },

  watch: {
    taxon: {
      handler (newVal, oldVal) {
        if (newVal.id && !oldVal.id) {
          this.tabIndex = getTabIndex(this.setTabView())
        }
      }
    }
  },

  methods: {
    setTabView () {
      if (this.verbatimFieldsWithData) {
        return TAB.Verbatim
      } else if (this.hasCitation) {
        return TAB.Source
      } else if (this.hasRoles) {
        return TAB.Person
      } else {
        return TAB.Source
      }
    }
  }
}
</script>
