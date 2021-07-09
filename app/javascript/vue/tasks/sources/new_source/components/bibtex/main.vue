<template>
  <div class="panel content">
    <h3>BibTeX</h3>
    <div class="horizontal-left-content align-start">
      <draggable
        class="vue-new-source-task-bibtex full_width"
        v-for="(column, key) in columns"
        v-model="columns[key]"
        :key="key"
        :item-key="element => element"
        :disabled="!sortable"
        :group="{ name: 'components' }"
        @end="updatePreferences">
        <template #item="{ element }">
          <component
            class="separate-bottom separate-right"
            @onModal="setDraggable"
            :is="element"/>
        </template>
      </draggable>
    </div>
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
import { User } from 'routes/endpoints'

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
      keyStorage: 'tasks::newsource::bibtex'
    }
  },

  watch: {
    preferences: {
      handler () {
        if (this.preferences.hasOwnProperty('layout')) {
          if (this.preferences.layout[this.keyStorage] && Object.keys(this.columns).every((key) => Object.keys(this.preferences.layout[this.keyStorage]).includes(key)))
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

    updatePreferences () {
      User.update(this.preferences.id, { user: { layout: { [this.keyStorage]: this.columns } } }).then(response => {
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
