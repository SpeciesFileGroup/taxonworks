<template>
  <div class="alternate_values_annotator">
    <div>
      <switch-component
        :options="tabs"
        use-index
        v-model="alternateType"
      />
    </div>
    <ul class="no_bullets content">
      <li
        v-for="(item, key) in values"
        :key="item">
        <label>
          <input
            type="radio"
            v-model="alternateValue.alternate_value_object_attribute"
            :value="key">
          "{{ key }}" -> {{ item }}
        </label>
      </li>
    </ul>

    <fieldset v-if="alternateValue.type === ALTERNATE_VALUE_TRANSLATION">
      <legend>Language</legend>
      <smart-selector
        v-model="language"
        model="languages"
        klass="AlternateValue"
        label="english_name"
        @selected="setLanguage"/>
      <SmartSelectorItem
        :item="language"
        label="english_name"
        @unset="setLanguage"
      />
    </fieldset>

    <div class="field margin-medium-top">
      <input
        class="normal-input full_width"
        type="text"
        v-model="alternateValue.value"
        placeholder="Value">
    </div>

    <v-btn
      class="margin-small-right"
      color="create"
      medium
      :disabled="!validateFields"
      @click="saveAlternateValue">
      Save
    </v-btn>
    <v-btn
      color="primary"
      medium
      @click="reset">
      New
    </v-btn>
  </div>

  <display-list
    label="object_tag"
    :list="list"
    edit
    @edit="loadAlternateValue"
    @delete="removeItem"
  />
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import SwitchComponent from 'components/switch.vue'
import DisplayList from 'components/displayList.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { addToArray } from 'helpers/arrays.js'
import {
  ALTERNATE_VALUE_ABBREVIATION,
  ALTERNATE_VALUE_ALTERNATE_SPELLING,
  ALTERNATE_VALUE_MISSPELLING,
  ALTERNATE_VALUE_TRANSLATION
} from 'constants/index.js'
import { AlternateValue, Language } from 'routes/endpoints'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    SmartSelector,
    SmartSelectorItem,
    DisplayList,
    SwitchComponent,
    VBtn
  },

  computed: {
    validateFields () {
      return this.alternateValue.value &&
        this.alternateValue.alternate_value_object_attribute
    },

    tabs () {
      return Object.values(this.typeList)
    },

    alternateType: {
      get () {
        return Object.keys(this.typeList).findIndex(item => item === this.alternateValue.type)
      },
      set (value) {
        this.alternateValue.type = Object.keys(this.typeList)[value]
      }
    }
  },

  created () {
    this.getList(`/alternate_values/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
      this.values = response.body
    })
  },

  data () {
    return {
      values: undefined,
      typeList: {
        [ALTERNATE_VALUE_TRANSLATION]: 'Translation',
        [ALTERNATE_VALUE_ABBREVIATION]: 'Abbreviation',
        [ALTERNATE_VALUE_MISSPELLING]: 'Misspelled',
        [ALTERNATE_VALUE_ALTERNATE_SPELLING]: 'Alternate spelling'
      },
      ALTERNATE_VALUE_TRANSLATION,
      language: undefined,
      alternateValue: this.newAlternate(),
      tabIndex: 0
    }
  },

  methods: {
    newAlternate () {
      return {
        value: undefined,
        language_id: undefined,
        type: ALTERNATE_VALUE_TRANSLATION,
        alternate_value_object_attribute: undefined
      }
    },

    saveAlternateValue () {
      const alternate_value = {
        ...this.alternateValue,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }

      const saveRequest = alternate_value.id
        ? AlternateValue.update(alternate_value.id, { alternate_value })
        : AlternateValue.create({ alternate_value })

      saveRequest.then(response => {
        addToArray(this.list, response.body)
        this.reset()
        TW.workbench.alert.create('Alternate value was successfully saved.', 'notice')
      })
    },

    reset () {
      this.alternateValue = this.newAlternate()
      this.language = undefined
    },

    setLanguage (language) {
      this.alternateValue.language_id = language?.id
      this.language = language
    },

    loadAlternateValue ({ id, value, alternate_value_object_attribute, language_id, type }) {
      this.alternateValue = {
        id,
        value,
        alternate_value_object_attribute,
        type,
        language_id
      }

      Language.find(language_id).then(({ body }) => {
        this.language = body
      })
    }
  }
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 50%;
}
</style>
