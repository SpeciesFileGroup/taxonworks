<template>
  <div class="panel content">
    <h2>BibTeX</h2>
    <draggable
      class="vue-new-source-task-bibtex "
      v-model="componentsOrder"
      :options="{ disabled: disableDraggable }"
      @end="updatePreferences">
      <component
        class="separate-bottom separate-right"
        v-for="componentName in componentsOrder"
        @onModal="setDraggable"
        :key="componentName"
        :is="componentName"/>
    </draggable>
  </div>
</template>

<script>

import BibtexType from './type'
import BibtexTitle from './title'
import BibtexAuthors from './author'
import BibtexDate from './date'
import BibtexSerial from './serial'
import BibtexVolume from './volume'
import BibtexLanguage from './language'
import BibtexLanguageId from './languageId'
import BibtexChapter from './chapter'
import BibtexBookTitle from './booktitle'
import BibtexEdition from './edition'
import BibtexSeries from './series'
import BibtexSourceEditor from './sourceEditor'
import BibtexOrganization from './organization'
import BibtexInstitution from './institution'
import BibtexHowpublished from './howPublished'
import BibtexPublisher from './publisher'
import BibtexAddress from './address'
import BibtexSchool from './School'
import BibtexCopyright from './copyright'
import BibtexTranslator from './translator'
import BibtexAbstract from './abstract'
import BibtexKey from './key'
import BibtexUrl from './url'
import BibtexVerbatim from './verbatimBibtex'
import BibtexCrosslinks from './crosslinks'
import BibtexTwAttributes from './twAttributes'

import Draggable from 'vuedraggable'

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import { UpdateUserPreferences } from '../../request/resources'

export default {
  components: {
    Draggable,
    BibtexType,
    BibtexTitle,
    BibtexAuthors,
    BibtexDate,
    BibtexSerial,
    BibtexVolume,
    BibtexLanguage,
    BibtexLanguageId,
    BibtexChapter,
    BibtexBookTitle,
    BibtexEdition,
    BibtexSeries,
    BibtexSourceEditor,
    BibtexOrganization,
    BibtexInstitution,
    BibtexHowpublished,
    BibtexPublisher,
    BibtexAddress,
    BibtexSchool,
    BibtexCopyright,
    BibtexTranslator,
    BibtexAbstract,
    BibtexKey,
    BibtexUrl,
    BibtexVerbatim,
    BibtexCrosslinks,
    BibtexTwAttributes
  },
  computed: {
    preferences: {
      get() {
        return this.$store.getters[GetterNames.GetPreferences]
      },
      set(value) {
        this.$store.commit(MutationNames.SetPreferences, value)
      }      
    }
  },
  data () {
    return {
      disableDraggable: false,
      componentsOrder: ['BibtexType', 'BibtexTitle', 'BibtexAuthors', 'BibtexDate', 'BibtexSerial', 'BibtexVolume', 'BibtexLanguageId', 'BibtexChapter', 'BibtexBookTitle', 'BibtexEdition', 'BibtexSeries', 'BibtexSourceEditor', 'BibtexOrganization', 'BibtexInstitution', 'BibtexHowpublished', 'BibtexPublisher', 'BibtexAddress', 'BibtexSchool', 'BibtexCopyright', 'BibtexTranslator', 'BibtexLanguage', 'BibtexAbstract', 'BibtexKey', 'BibtexUrl', 'BibtexVerbatim', 'BibtexCrosslinks', 'BibtexTwAttributes'],
      keyStorage: 'tasks::newsource::bibtex'
    }
  },
  watch: {
    preferences: {
      handler(newVal) {
        if(this.preferences.hasOwnProperty('layout')) {
          if(this.preferences.layout[this.keyStorage] && this.componentsOrder.length == this.preferences.layout[this.keyStorage].length)
            this.componentsOrder = this.preferences.layout[this.keyStorage]
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
      UpdateUserPreferences(this.preferences.id, { [this.keyStorage]: this.componentsOrder }).then(response => {
        this.preferences.layout = response.body.preferences
        this.componentsOrder = response.body.preferences.layout[this.keyStorage]
      })
    }
  }
}
</script>

<style lang="scss">
  .vue-new-source-task-bibtex {
    max-height: 1000px;
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
