<template>
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <select
        class="full_width margin-medium-bottom"
        v-model="keySelected"
      >
        <option :value="undefined">Select a key</option>
        <option
          v-for="item in keys"
          :key="item.id"
          :value="item"
        >
          {{ item.text }}
        </option>
      </select>
      <div
        v-if="keySelected"
        class="flex-separate margin-small-bottom"
      >
        <VBtn
          color="create"
          :disabled="!rowsSelected.length"
          @click="addRows"
        >
          Add OTUs
        </VBtn>
        <div
          class="horizontal-right-content middle gap-small"
          v-if="keySelected"
        >
          <VBtn
            color="primary"
            @click="selectAll"
          >
            Select all
          </VBtn>
          <VBtn
            color="primary"
            @click="unselectAll"
          >
            Unselect all
          </VBtn>
        </div>
      </div>
      <ul class="no_bullets">
        <li
          v-for="item in rows"
          :key="item.id"
        >
          <label>
            <input
              type="checkbox"
              :value="item"
              v-model="rowsSelected"
              :disabled="alreadyExist(item)"
            />
            <span
              class="disabled"
              v-if="alreadyExist(item)"
            >
              <span v-html="item.object_tag" />
              <span>(Already added)</span>
            </span>
            <span
              v-else
              v-html="item.object_tag"
            />
          </label>
        </li>
      </ul>

      <div class="flex-separate middle gap-small">
        <VBtn
          color="create"
          :disabled="!rowsSelected.length"
          @click="addRows"
        >
          Add OTUs
        </VBtn>
        <div
          class="horizontal-right-content middle gap-small"
          v-if="keySelected"
        >
          <VBtn
            color="primary"
            @click="selectAll"
          >
            Select all
          </VBtn>
          <VBtn
            color="primary"
            @click="unselectAll"
          >
            Unselect all
          </VBtn>
        </div>
      </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import { Lead } from '@/routes/endpoints'
import { ref, watch, onBeforeMount } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  existingOtus: {
    type: Array,
    required: true
  }
})

const keySelected = ref()
const isLoading = ref(false)
const rows = ref([])
const keys = ref([])
const rowsSelected = ref([])

const emit = defineEmits(['selected'])

onBeforeMount(() => {
  isLoading.value = true
  Lead.where({ per: 500 }).then(({ body }) => {
    keys.value = body
    isLoading.value = false
  })
})

watch(keySelected, (newVal) => {
  if (newVal) {
    loadRows()
  } else {
    rows.value = []
  }
})

function loadRows() {
  isLoading.value = true

  Lead.otus(keySelected.value.id).then((response) => {
    rows.value = rows.value.concat(response.body)
    isLoading.value = false
  })
}

function addRows() {
  emit('selected', rowsSelected.value.map((item) => item.id))
}

function alreadyExist(item) {
  return props.existingOtus.find(
    (id) => item.id === id
  )
}

function selectAll() {
  rowsSelected.value = rows.value.filter((item) => !alreadyExist(item))
}

function unselectAll() {
  rowsSelected.value = []
}
</script>
