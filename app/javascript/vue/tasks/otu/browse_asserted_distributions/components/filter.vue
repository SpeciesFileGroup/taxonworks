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
      <Otu
        v-model="params.base.asserted_distribution_object_id"
      />
      <NavBar
        :otu-id="params.base.asserted_distribution_object_id"
      />
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import Otu from './filters/otu.vue'
import NavBar from './navBar.vue'
import { AssertedDistribution } from '@/routes/endpoints'
import { defineEmits, ref, watch } from 'vue'

const params = ref(initParams())
const result = ref([])
const searching = ref(false)

const emit = defineEmits(['reset'])

watch(() => [params.value.base.asserted_distribution_object_id,
  params.value.base.asserted_distribution_object_type],
(newVal) => {
  if (newVal[0] && newVal[1]) {
    search()
  }
})

function  resetFilter() {
  emit('reset', 'result', 'urlRequest')
  params.value = initParams()
}

function search() {
  const p = { ...params.value.base }

  searching.value = true
  AssertedDistribution.where(p)
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
    base: {
      // TODO: type will need to be chooseable
      asserted_distribution_object_type: 'Otu',
      asserted_distribution_object_id: undefined,
      embed: ['shape'],
      extend: ['asserted_distribution_shape']
    }
  }
}

</script>
<style scoped>
:deep(.btn-delete) {
  background-color: var(--color-primary);
}
</style>
