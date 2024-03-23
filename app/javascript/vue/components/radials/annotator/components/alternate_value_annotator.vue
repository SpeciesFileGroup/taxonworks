<template>
  <div class="alternate_values_annotator">
    <VSwitch
      :options="Object.values(TYPE_LIST)"
      use-index
      v-model="alternateType"
    />
    <ul class="no_bullets content">
      <li
        v-for="(item, key) in values"
        :key="item"
      >
        <label>
          <input
            type="radio"
            v-model="alternateValue.alternate_value_object_attribute"
            :value="key"
          />
          "{{ key }}" -> {{ item }}
        </label>
      </li>
    </ul>

    <fieldset v-if="alternateValue.type === ALTERNATE_VALUE_TRANSLATION">
      <legend>Language</legend>
      <SmartSelector
        v-model="language"
        model="languages"
        klass="AlternateValue"
        label="english_name"
        @selected="setLanguage"
      />
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
        placeholder="Value"
      />
    </div>

    <VBtn
      class="margin-small-right"
      color="create"
      medium
      :disabled="!validateFields"
      @click="saveAlternateValue"
    >
      Save
    </VBtn>
    <VBtn
      color="primary"
      medium
      @click="reset"
    >
      New
    </VBtn>
  </div>

  <DisplayList
    label="object_tag"
    :list="list"
    edit
    @edit="loadAlternateValue"
    @delete="removeItem"
  />
</template>

<script setup>
import {
  ALTERNATE_VALUE_ABBREVIATION,
  ALTERNATE_VALUE_ALTERNATE_SPELLING,
  ALTERNATE_VALUE_MISSPELLING,
  ALTERNATE_VALUE_TRANSLATION
} from '@/constants/index.js'
import { AlternateValue, Language } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { useSlice } from '@/components/radials/composables'
import VSwitch from '@/components/ui/VSwitch.vue'
import DisplayList from '@/components/displayList.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import makeRequest from '@/helpers/ajaxCall.js'

const TYPE_LIST = {
  [ALTERNATE_VALUE_TRANSLATION]: 'Translation',
  [ALTERNATE_VALUE_ABBREVIATION]: 'Abbreviation',
  [ALTERNATE_VALUE_MISSPELLING]: 'Misspelled',
  [ALTERNATE_VALUE_ALTERNATE_SPELLING]: 'Alternate spelling'
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  globalId: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})
const values = ref()
const language = ref()
const alternateValue = ref(newAlternate())

const validateFields = computed(() => {
  return (
    alternateValue.value.value &&
    alternateValue.value.alternate_value_object_attribute &&
    (alternateValue.value.type === ALTERNATE_VALUE_TRANSLATION
      ? language.value
      : true)
  )
})

const alternateType = computed({
  get: () =>
    Object.keys(TYPE_LIST).findIndex(
      (item) => item === alternateValue.value.type
    ),
  set(value) {
    alternateValue.value.type = Object.keys(TYPE_LIST)[value]
  }
})

makeRequest(
  'get',
  `/alternate_values/${encodeURIComponent(props.globalId)}/metadata`
).then((response) => {
  values.value = response.body
})

function newAlternate() {
  return {
    value: undefined,
    language_id: undefined,
    type: ALTERNATE_VALUE_TRANSLATION,
    alternate_value_object_attribute: undefined
  }
}

function saveAlternateValue() {
  const payload = {
    alternate_value: {
      ...alternateValue.value,
      alternate_value_object_id: props.objectId,
      alternate_value_object_type: props.objectType
    }
  }

  const saveRequest = alternateValue.value.id
    ? AlternateValue.update(alternateValue.value.id, payload)
    : AlternateValue.create(payload)

  saveRequest.then(({ body }) => {
    addToList(body)
    reset()
    TW.workbench.alert.create(
      'Alternate value was successfully saved.',
      'notice'
    )
  })
}

function reset() {
  alternateValue.value = newAlternate()
  language.value = undefined
}

function setLanguage(language) {
  alternateValue.value.language_id = language?.id
  language.value = language
}

function loadAlternateValue({
  id,
  value,
  alternate_value_object_attribute,
  language_id,
  type
}) {
  alternateValue.value = {
    id,
    value,
    alternate_value_object_attribute,
    type,
    language_id
  }

  Language.find(language_id).then(({ body }) => {
    language.value = body
  })
}

function removeItem(item) {
  AlternateValue.destroy(item.id).then((_) => {
    removeFromList(item)
  })
}

AlternateValue.where({
  alternate_value_object_id: props.objectId,
  alternate_value_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 50%;
}
</style>
