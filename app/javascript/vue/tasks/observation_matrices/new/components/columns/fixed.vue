<template>
  <BlockLayout>
    <template #header>
      <h3>Columns</h3>
    </template>
    <template #body>
      <SmartSelector
        :options="smartOptions"
        :add-option="DEFAULT_OPTIONS"
        v-model="view"
        name="rows-smart"
      />
      <component
        :is="currentComponent"
        :batch-type="view"
        :matrix-id="matrix.id"
        :list="lists[view]"
        type="descriptor"
        @close="view = undefined"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { GetMatrixColumnMetadata } from '../../request/resources'
import SmartSelector from '../shared/smartSelector.vue'
import pinboard from './batchView.vue'
import keywords from './keywordView.vue'
import search from './search.vue'
import FromAnotherMatrix from './copyDescriptors'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const DEFAULT_OPTIONS = ['search', 'From Another Matrix']

const COMPONENTS = {
  keywords,
  pinboard,
  search,
  FromAnotherMatrix
}

const store = useStore()

const matrix = computed(() => store.getters[GetterNames.GetMatrix])
const currentComponent = computed(() => COMPONENTS[removeSpaces(view.value)])

const smartOptions = ref([])
const view = ref()
const lists = ref([])

GetMatrixColumnMetadata().then(({ body }) => {
  smartOptions.value = [...Object.keys(body)]
  lists.value = body
})

function removeSpaces(line) {
  return line?.replace(/ /g, '')
}
</script>
