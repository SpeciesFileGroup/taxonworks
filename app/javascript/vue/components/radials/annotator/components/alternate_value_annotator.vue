<template>
  <div class="alternate_values_annotator">
    <div>
      <switch-component
        :options="tabs"
        use-index
        v-model="tabIndex"
      />
    </div>
    <div v-if="alternateType">
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

      <autocomplete
        v-if="alternateType == ALTERNATE_VALUE_TRANSLATION"
        class="field"
        url="/languages/autocomplete"
        label="label"
        min="2"
        placeholder="Language"
        @getItem="alternateValue.language_id = $event.id"
        param="term"
      />

      <div class="separate-bottom">
        <div class="field">
          <input
            type="text"
            class="normal-input"
            v-model="alternateValue.value"
            placeholder="Value">
        </div>
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createNew()">
          Create
        </button>
      </div>
    </div>

    <display-list
      label="object_tag"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import Autocomplete from 'components/ui/Autocomplete.vue'
import SwitchComponent from 'components/switch.vue'
import DisplayList from './displayList.vue'
import {
  ALTERNATE_VALUE_ABBREVIATION,
  ALTERNATE_VALUE_ALTERNATE_SPELLING,
  ALTERNATE_VALUE_MISSPELLING,
  ALTERNATE_VALUE_TRANSLATION
} from 'constants/index.js'
import { AlternateValue } from 'routes/endpoints'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    Autocomplete,
    DisplayList,
    SwitchComponent
  },

  computed: {
    validateFields () {
      return this.alternateValue.value &&
        this.alternateValue.alternate_value_object_attribute
    },

    tabs () {
      return Object.values(this.typeList)
    },

    alternateType () {
      return Object.keys(this.typeList)[this.tabIndex]
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
        [ALTERNATE_VALUE_TRANSLATION]: 'translation',
        [ALTERNATE_VALUE_ABBREVIATION]: 'abbreviation',
        [ALTERNATE_VALUE_MISSPELLING]: 'misspelled',
        [ALTERNATE_VALUE_ALTERNATE_SPELLING]: 'alternate spelling'
      },
      ALTERNATE_VALUE_TRANSLATION,
      alternateValue: this.newAlternate(),
      tabIndex: 0
    }
  },

  methods: {
    newAlternate () {
      return {
        value: undefined,
        language_id: undefined,
        alternate_value_object_attribute: undefined
      }
    },

    createNew () {
      const alternate_value = {
        ...this.alternateValue,
        type: this.alternateType,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }

      AlternateValue.create({ alternate_value }).then(response => {
        this.list.push(response.body)
        this.alternateValue = this.newAlternate()
      })
    }
  }
}
</script>
