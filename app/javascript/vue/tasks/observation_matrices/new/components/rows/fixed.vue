<template>
  <BlockLayout>
    <template #header>
      <h3>Rows</h3>
    </template>
    <template #body>
      <SmartSelector
        :options="smartOptions"
        :add-option="moreOptions"
        v-model="view"
        name="rows-smart"
      />
      <component
        :is="currentComponent"
        :matrix-id="matrix.id"
        :batch-type="view"
        :list="lists[view]"
        @close="view = undefined"
      />
    </template>
  </BlockLayout>
</template>
<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetMatrixRowMetadata } from '../../request/resources'
import { GetterNames } from '../../store/getters/getters'
import SmartSelector from '../shared/smartSelector.vue'
import pinboard from './batchView.vue'
import keywords from './keywordView.vue'
import Search from './search.vue'
import FromAnotherMatrix from './copyRows'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const COMPONENTS = {
  pinboard,
  keywords,
  Search,
  FromAnotherMatrix
}

const store = useStore()

const matrix = computed(() => store.getters[GetterNames.GetMatrix])
const currentComponent = computed(() => COMPONENTS[removeSpaces(view.value)])

const view = ref()
const smartOptions = ref([])
const moreOptions = ref(['Search', 'From Another Matrix'])
const lists = ref([])

function removeSpaces(line) {
  return line?.replace(/ /g, '')
}

GetMatrixRowMetadata().then(({ body }) => {
  smartOptions.value = Object.keys(body)
  lists.value = body
})
</script>
