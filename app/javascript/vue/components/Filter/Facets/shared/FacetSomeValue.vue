<template>
  <FacetContainer>
    <h3>Some value in</h3>
    <select @change="addAttribute">
      <option selected>
        Select an attribute
      </option>
      <option
        v-for="name in filteredList"
        :key="name"
        :value="name"
        @click="addAttribute(item)"
      >
        {{ name }}
      </option>
    </select>
    <table
      v-if="selectedAttributes.length"
      class="vue-table"
    >
      <thead>
        <tr>
          <th>Name</th>
          <th />
          <th />
        </tr>
      </thead>
      <tbody>
        <row-item
          v-for="(item, index) in selectedAttributes"
          :key="index"
          class="list-complete-item"
          :item="item"
          label="name"
          v-model="item.empty"
          @remove="removeAttr(index)"
        />
      </tbody>
    </table>
  </FacetContainer>
</template>

<script setup>

import AjaxCall from 'helpers/ajaxCall'
import { ref, computed, watch, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import RowItem from 'components/Filter/Facets/shared/RowItem.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  model: {
    type: String,
    required: true
  },

  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const attributes = ref([])
const selectedAttributes = ref([])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const filteredList = computed(() =>
  attributes.value
    .map(attr => attr.name)
    .filter(attr =>
      !selectedAttributes.value.find(({ name }) => name === attr)
    ))

watch(
  selectedAttributes,
  () => {
    params.value.empty = selectedAttributes.value.filter(attr => attr.empty)
    params.value.not_empty = selectedAttributes.value.filter(attr => !attr.empty)
  },
  { deep: true }
)

onBeforeMount(async () => {
  const urlParams = URLParamsToJSON(location.href)

  attributes.value = (await AjaxCall('get', `/${props.model}/attributes`)).body

  const {
    empty = [],
    not_empty = []
  } = urlParams

  selectedAttributes.value = [].concat(
    empty.map(name => ({ name, empty: true })),
    not_empty.map(name => ({ name, empty: false }))
  )
})

const addAttribute = (event) => {
  const name = event.target.value
  if (!name) return
  selectedAttributes.value.push({
    name,
    empty: false
  })
}

const removeAttr = (index) => {
  selectedAttributes.value.splice(index, 1)
}
</script>
