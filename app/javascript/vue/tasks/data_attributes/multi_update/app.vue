<template>
  <div class="flex-separate middle">
    <h1>Multi-update data attributes</h1>
    <ul class="context-menu">
      <li>
        <label
          title="When checked, pasting blank cells will delete existing records."
        >
          <input
            type="checkbox"
            v-model="store.settings.override"
          />
          Allow override with blanks
        </label>
      </li>
      <li>
        <label
          title="Enable this option to append clipboard content to the existing cell value instead of replacing it when pasting."
        >
          <input
            type="checkbox"
            v-model="store.settings.append"
          />
          Append
        </label>
      </li>
      <li>
        <label>
          <input
            type="checkbox"
            v-model="isPredicatePanelVisible"
          />
          Show predicate panel
        </label>
      </li>
    </ul>
  </div>
  <div class="horizontal-left-content align-start gap-medium">
    <VSpinner
      v-if="store.isLoading"
      full-screen
    />
    <VSpinner
      v-if="store.isSaving"
      full-screen
      :legend="`Saving... please wait. ${store.save.current} of ${store.save.total}.`"
    />
    <PredicateSelector v-show="isPredicatePanelVisible" />
    <DataAttributeTable />
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { useQueryParam } from '../field_synchronize/composables'
import PredicateSelector from './components/PredicateSelector.vue'
import useStore from './store/store'
import DataAttributeTable from './components/DataAttributeTable.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'MultiUpdate'
})

const store = useStore()
const { queryParam, queryValue } = useQueryParam()

const isPredicatePanelVisible = ref(true)

onBeforeMount(() => {
  if (queryParam.value) {
    store.loadObjects({
      queryParam: queryParam.value,
      queryValue: queryValue.value
    })
  }
})
</script>
