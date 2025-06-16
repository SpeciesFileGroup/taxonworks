<template>
  <div class="panel">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetFilter"
      >
        Reset
      </span>
    </div>
    <VSpinner
      v-if="searching"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <div class="content">
      <AssertedDistributionObjectPicker
        minimal
        autofocus
        @select-object="(o) => {
          params.asserted_distribution_object = o
        }"
      />
      <NavBar
        :asserted-distribution-object="params.asserted_distribution_object"
      />
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import NavBar from './navBar.vue'
import { AssertedDistribution } from '@/routes/endpoints'
import { ENDPOINTS_HASH } from '../const/endpoints'
import { MODEL_FOR_ID_PARAM } from '@/components/radials/filter/constants/idParams'
import { defineEmits, onMounted, ref, watch } from 'vue'
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'

const params = ref(initParams())
const result = ref([])
const searching = ref(false)

const emit = defineEmits(['reset', 'result', 'urlRequest'])

watch(() => params.value.asserted_distribution_object,
  (newVal) => {
    if (newVal) {
      search()
    }
})

function  resetFilter() {
  emit('reset')
  params.value = initParams()
}

function search() {
  const payload = {
    ...params.value.options,
    asserted_distribution_object_id:
      params.value.asserted_distribution_object.id,
    asserted_distribution_object_type:
      params.value.asserted_distribution_object.objectType,
  }

  searching.value = true
  AssertedDistribution.where(payload)
    .then((response) => {
      result.value = response.body
      emit('result', result.value)
      emit('urlRequest', response.request.responseURL)
      if (result.value.length === 500) {
        TW.workbench.alert.create('Results may be truncated.', 'notice')
      }
    })
    .catch(() => {})
    .finally(() => {
      searching.value = false
    })
}

function initParams() {
  return {
    asserted_distribution_object: undefined,
    options: {
      embed: ['shape'],
      extend: ['asserted_distribution_shape']
    }
  }
}

onMounted(() => {
  getParams()
})

function getParams() {
  const urlParams = new URLSearchParams(window.location.search)
  //const id = urlParams.get('otu_id')

  for (const p of urlParams.keys()) {
    const model = MODEL_FOR_ID_PARAM[p]
    const endpoint = ENDPOINTS_HASH[model]
    if (model && endpoint) {
      const id = urlParams.get(p)
      if (id && (/^\d+$/.test(id))) {
        loadObject(model, endpoint, id)
        break
      }
    }
  }
}

function loadObject(model, endpoint, id) {
  endpoint.find(id)
    .then(({ body }) => {
      body.objectType = model
      params.value.asserted_distribution_object = body
    })
    .catch(() => {})
}

</script>
<style scoped>
:deep(.btn-delete) {
  background-color: var(--color-primary);
}
</style>
