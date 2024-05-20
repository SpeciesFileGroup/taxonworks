<template>
  <fieldset>
    <legend>Data attributes</legend>
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      :custom-list="{ all }"
      :lock-view="false"
      @selected="
        (item) => {
          setDataAttribute(item)
        }
      "
      v-model="predicate"
    />
    <SmartSelectorItem
      :item="predicate"
      label="name"
      @unset="
        () => {
          predicate = undefined
          dataAttribute.controlled_vocabulary_term_id = undefined
        }
      "
    />

    <label>Value</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="dataAttribute.value"
    ></textarea>
    <button
      class="button normal-input button-default margin-medium-top"
      @click="addDataAttribute"
      :disabled="!validateFields"
      type="button"
    >
      Add
    </button>
    <TableList
      v-if="dataAttributes.length"
      :list="dataAttributes"
      :header="['Predicate', 'Value', '']"
      :delete-warning="false"
      soft-delete
      :annotator="false"
      row-key="controlled_vocabulary_term_id"
      :attributes="['label', 'value']"
      @delete="(item) => store.commit(MutationNames.RemoveDataAttribute, item)"
    />
  </fieldset>
</template>

<script setup>
import { useStore } from 'vuex'
import { ref, computed, onBeforeMount } from 'vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import TableList from '@/components/table_list'
import AjaxCall from '@/helpers/ajaxCall.js'

const store = useStore()

const dataAttributes = computed({
  get: () => store.getters[GetterNames.GetDataAttributes],
  set(value) {
    store.commit(MutationNames.SetDataAttributes, value)
  }
})

const validateFields = computed(
  () =>
    dataAttribute.value.controlled_vocabulary_term_id &&
    dataAttribute.value.value
)

const all = ref([])
const dataAttribute = ref(newDataAttribute())
const predicate = ref()

onBeforeMount(() => {
  AjaxCall('get', `/controlled_vocabulary_terms.json?type[]=Predicate`).then(
    (response) => {
      all.value = response.body
    }
  )
})

function newDataAttribute() {
  return {
    label: undefined,
    controlled_vocabulary_term_id: undefined,
    type: 'InternalAttribute',
    value: undefined
  }
}

function addDataAttribute() {
  store.commit(MutationNames.AddDataAttribute, dataAttribute.value)
  dataAttribute.value = newDataAttribute()
  predicate.value = undefined
}

function setDataAttribute(predicate) {
  predicate.value = predicate
  dataAttribute.value.label = predicate.name
  dataAttribute.value.controlled_vocabulary_term_id = predicate.id
}
</script>
