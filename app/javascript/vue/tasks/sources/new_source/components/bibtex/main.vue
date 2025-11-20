<template>
  <div class="horizontal-left-content align-start gap-small">
    <draggable
      v-for="(column, key) in columns"
      :key="key"
      class="vue-new-source-task-bibtex full_width gap-medium"
      v-model="columns[key]"
      :item-key="(element) => element"
      :disabled="!settings.sortable"
      :group="{ name: 'components' }"
      @end="updatePreferences"
    >
      <template #item="{ element }">
        <component
          :is="allComponents[element]"
          v-model="store.source"
          @on-modal="setDraggable"
        />
      </template>
    </draggable>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useSettingStore, useSourceStore } from '../../store'
import { useUserPreferences } from '@/composables'
import Draggable from 'vuedraggable'
import SourceType from '../sourceType'
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

const KEY_STORAGE = 'tasks::newsource::bibtex'
const COMPONENTS_GROUP = {
  componentsOrderOne: {
    SourceType,
    BibtexType,
    BibtexTitle,
    BibtexAuthors,
    BibtexDate,
    BibtexSerial,
    BibtexVolume,
    BibtexLanguageId,
    BibtexChapter,
    BibtexBookTitle,
    BibtexEdition,
    BibtexSeries
  },
  componentsOrderTwo: {
    BibtexSourceEditor,
    BibtexOrganization,
    BibtexInstitution,
    BibtexHowpublished,
    BibtexPublisher,
    BibtexAddress,
    BibtexSchool,
    BibtexCopyright,
    BibtexTranslator,
    BibtexLanguage,
    BibtexAbstract,
    BibtexKey,
    BibtexUrl
  },
  componentsOrderThree: { BibtexVerbatim, BibtexCrosslinks, BibtexTwAttributes }
}
const allComponents = getAllComponentsObject(COMPONENTS_GROUP)

const settings = useSettingStore()
const store = useSourceStore()
const { preferences, loadPreferences, setPreference } = useUserPreferences()

const disableDraggable = ref(false)

const columns = ref(getComponentKeys(COMPONENTS_GROUP))

function getAllComponentsObject(componentsGroup) {
  return Object.values(componentsGroup).reduce(
    (acc, group) => ({ ...acc, ...group }),
    {}
  )
}

function getComponentKeys(components) {
  return Object.fromEntries(
    Object.entries(components).map(([groupName, group]) => [
      groupName,
      Object.keys(group)
    ])
  )
}

function getAllComponentKeys(componentsGroup) {
  return Object.values(componentsGroup).flatMap((group) => Object.keys(group))
}

loadPreferences().then(() => {
  if (preferences.value.layout?.[KEY_STORAGE]) {
    const componentNames = getAllComponentKeys(COMPONENTS_GROUP)
    const userLayoutComponentNames = Object.values(
      preferences.value.layout[KEY_STORAGE]
    ).flat()

    const hasTheSameAmount =
      componentNames.length === userLayoutComponentNames.length
    const hasTheSameComponents = componentNames.every((name) =>
      userLayoutComponentNames.includes(name)
    )

    if (hasTheSameAmount && hasTheSameComponents) {
      columns.value = preferences.value.layout[KEY_STORAGE]
    }
  }
})

function setDraggable(mode) {
  disableDraggable.value = mode
}

function updatePreferences() {
  setPreference(KEY_STORAGE, columns.value)
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

  input[type='text'] {
    width: 100%;
  }
}
</style>
