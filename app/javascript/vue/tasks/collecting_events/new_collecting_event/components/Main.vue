<template>
  <div class="panel content">
    <h2>BibTeX</h2>
    <div class="horizontal-left-content align-start">
      <draggable
        class="vue-new-source-task-bibtex full_width"
        v-for="(column, key) in columns"
        v-model="columns[key]"
        :key="key"
        :disabled="!sortable"
        :group="{ name: 'components' }"
        @end="updatePreferences">
        <component
          class="separate-bottom separate-right"
          v-for="componentName in column"
          @onModal="setDraggable"
          :key="componentName"
          :is="componentName"/>
      </draggable>
    </div>
  </div>
</template>

<script>

import VerbatimCollectors from './verbatim/collectors'

import Draggable from 'vuedraggable'

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import { UpdateUserPreferences } from '../../request/resources'

export default {
  components: {
    Draggable,
    VerbatimCollectors,
  },
  computed: {
    preferences: {
      get () {
        return this.$store.getters[GetterNames.GetPreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPreferences, value)
      }
    },
    sortable () {
      return this.$store.getters[GetterNames.GetSettings].sortable
    }
  },
  data () {
    return {
      disableDraggable: false,
      columns: {
        componentsOrderOne: ['BibtexType', 'BibtexTitle', 'BibtexAuthors', 'BibtexDate', 'BibtexSerial', 'BibtexVolume', 'BibtexLanguageId', 'BibtexChapter', 'BibtexBookTitle', 'BibtexEdition', 'BibtexSeries',],
        componentsOrderTwo: ['BibtexSourceEditor', 'BibtexOrganization', 'BibtexInstitution', 'BibtexHowpublished', 'BibtexPublisher', 'BibtexAddress', 'BibtexSchool', 'BibtexCopyright', 'BibtexTranslator', 'BibtexLanguage', 'BibtexAbstract', 'BibtexKey', 'BibtexUrl'],
        componentsOrderThree: ['BibtexVerbatim', 'BibtexCrosslinks', 'BibtexTwAttributes'],
      },
      keyStorage: 'tasks::newcollectingevent'
    }
  },
  watch: {
    preferences: {
      handler(newVal) {
        if (this.preferences.hasOwnProperty('layout')) {
          if (this.preferences.layout[this.keyStorage] && Object.keys(this.columns).every((key) => { return Object.keys(this.preferences.layout[this.keyStorage]).includes(key) }))
            this.columns = this.preferences.layout[this.keyStorage]
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    setDraggable (mode) {
      this.disableDraggable = mode
    },
    updatePreferences() {
      UpdateUserPreferences(this.preferences.id, { [this.keyStorage]: this.columns }).then(response => {
        this.preferences.layout = response.body.preferences
        this.columns = response.body.preferences.layout[this.keyStorage]
      })
    }
  }
}
</script>

<style lang="scss">
  .vue-new-source-task-bibtex {
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;

    textarea {
      width: 100%;
      height: 80px;
    }

    > div {
      margin-right: 14px;
    }
    
    input[type="text"] {
      width: 100%;
    }
  }
</style>
