<template>
  <div class="horizontal-left-content middle gap-small text-xs">
    <span v-if="haveRecords">
      {{ formatNumber(recordsAtCurrentPage) }}–{{
        formatNumber(recordsAtNextPage)
      }}
      of {{ formatNumber(pagination.total) }}
    </span>
    <span v-else>0 records</span>
    <div class="horizontal-left-content middle gap-xsmall">
      <input
        v-if="inputMode"
        ref="customRef"
        class="w-16"
        type="number"
        min="1"
        v-model="customValue"
        @change="setCustomValue"
        @keydown.escape="inputMode = false"
        @blur="inputMode = false"
      />
      <select
        v-else
        :value="per"
        @change="handleSelectChange"
      >
        <option
          v-for="records in perList"
          :key="records"
          :value="records"
        >
          {{ records }}
        </option>
        <option
          v-if="custom"
          :value="CUSTOM_OPTION"
        >
          Custom…
        </option>
      </select>
      per page
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref, useTemplateRef, nextTick } from 'vue'

const props = defineProps({
  pagination: {
    type: Object,
    required: true
  },

  maxRecords: {
    type: Array,
    default: () => [50, 100, 250, 500, 1000, 2500]
  },

  custom: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['change'])

const CUSTOM_OPTION = 'custom'

const per = defineModel({
  type: [String, Number],
  required: true
})
const customValue = ref()
const inputMode = ref(false)
const inputCustom = useTemplateRef('customRef')

const perList = computed(() => {
  if (customValue.value) {
    return props.maxRecords.includes(customValue.value)
      ? props.maxRecords
      : [...props.maxRecords, customValue.value].toSorted((a, b) => a - b)
  }
  return props.maxRecords.toSorted((a, b) => a - b)
})

const recordsAtCurrentPage = computed(
  () => (props.pagination.paginationPage - 1) * props.pagination.perPage + 1
)

const recordsAtNextPage = computed(() => {
  const recordsCount =
    props.pagination.paginationPage * props.pagination.perPage
  return recordsCount > props.pagination.total
    ? props.pagination.total
    : recordsCount
})

const haveRecords = computed(() => Number(props.pagination.total))

function formatNumber(value) {
  return Number(value).toLocaleString()
}

function handleSelectChange(e) {
  if (e.target.value === CUSTOM_OPTION) {
    e.target.value = per.value
    inputMode.value = true
    nextTick(() => inputCustom.value.focus())
    return
  }

  per.value = Number(e.target.value)
  emit('change', per.value)
}

function setCustomValue() {
  const value = Number(customValue.value)

  if (value > 0) {
    per.value = value
  }

  inputMode.value = false
}

onBeforeMount(() => {
  const perValue = Number(per.value)
  if (!perList.value.includes(perValue)) {
    customValue.value = perValue
  }
})
</script>
