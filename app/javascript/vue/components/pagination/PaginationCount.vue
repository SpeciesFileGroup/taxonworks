<template>
  <div class="horizontal-left-content gap-small">
    <span
      v-if="haveRecords"
      class="horizontal-left-content"
    >
      {{ recordsAtCurrentPage }} - {{ recordsAtNextPage }} of
      {{ pagination.total }} records.
    </span>
    <span v-else>0 records.</span>
    <div class="horizontal-left-content middle">
      <input
        v-if="inputMode"
        ref="customRef"
        class="w-16"
        type="number"
        v-model="customValue"
        @change="
          (e) => {
            per = e.target.value
            inputMode = false
          }
        "
      />
      <select
        v-else
        v-model="per"
        @change="(e) => emit('change', per)"
      >
        <option
          v-for="records in perList"
          :key="records"
          :value="records"
        >
          {{ records }}
        </option>
      </select>

      <VBtn
        v-if="custom"
        class="rounded-tl-none rounded-bl-none"
        color="primary"
        medium
        @click="toggleMode"
      >
        <VIcon
          name="pencil"
          x-small
        />
      </VBtn>
    </div>
    records per page.
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref, useTemplateRef, nextTick } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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
  () => (props.pagination.paginationPage - 1) * props.pagination.perPage || 1
)

const recordsAtNextPage = computed(() => {
  const recordsCount =
    props.pagination.paginationPage * props.pagination.perPage
  return recordsCount > props.pagination.total
    ? props.pagination.total
    : recordsCount
})

const haveRecords = computed(() => Number(props.pagination.total))

function toggleMode() {
  inputMode.value = !inputMode.value

  if (inputMode.value) {
    nextTick(() => inputCustom.value.focus())
  }
}

onBeforeMount(() => {
  const perValue = Number(per.value)
  if (!perList.value.includes(perValue)) {
    customValue.value = perValue
  }
})
</script>
