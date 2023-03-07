<template>
  <FacetContainer>
    <h3>Updated</h3>
    <datalist id="days">
      <option
        v-for="(option, index) in OPTIONS"
        :key="option.value"
        :value="index"
      />
    </datalist>
    <input
      type="range"
      list="days"
      min="0"
      max="4"
      step="0"
      v-model="optionValue"
    >
    <div class="options-label">
      <span
        v-for="option in OPTIONS"
        :key="option.value"
        v-html="option.label"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const optionValue = computed({
  get: () => params.value.updated_since ? OPTIONS.findIndex(opt => opt.value === parseDateIntoDays(params.value.updated_since)) || 0 : 0,
  set: value => { params.value.updated_since = setDays(OPTIONS[value].value) }
})

const OPTIONS = [
  {
    value: undefined,
    label: 'Any time'
  },
  {
    value: 1,
    label: '1'
  },
  {
    value: 10,
    label: '10'
  },
  {
    value: 100,
    label: '100'
  },
  {
    value: 365,
    label: '365'
  }
]

onBeforeMount(() => {
  params.value.updated_since = URLParamsToJSON(location.href).updated_since
})

const parseDateIntoDays = (updateDate) => {
  const date = new Date(updateDate)
  const today = new Date()
  const diffInTyme = today.getTime() - date.getTime()
  const dffInDay = diffInTyme / (1000 * 3600 * 24)

  return Math.floor(dffInDay)
}

const setDays = days => {
  const date = new Date()

  date.setDate(date.getDate() - days)
  return date.toISOString().slice(0, 10)
}
</script>

<style lang="scss" scoped>
.options-label {
  display: flex;
  width: 262px;
  padding: 0 21px;
  margin-top: -10px;
  justify-content: space-between;
  span {
    position: relative;
    display: flex;
    justify-content: center;
    text-align: center;
    width: 1px;
    white-space: nowrap;
    background: #D3D3D3;
    height: 10px;
    line-height: 40px;
    margin: 0 0 20px 0;
  }
}
  datalist {
    display: flex;
    justify-content: space-between;
    margin-top: -23px;
    padding-top: 0px;
    width: 300px;
  }
  input[type="range"] {
    width: 300px;
  }

</style>
