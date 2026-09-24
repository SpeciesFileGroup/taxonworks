<template>
  <BlockLayout :warning="!store.environment">
    <template #header>
      <h3>Environment</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start gap-small">
        <AutoselectField
          class="full_width"
          url="/asserted_environments/autoselect"
          param="uri"
          placeholder="Search ENVO, or terms already used in this project"
          reset-on-select
          @select="setEnvironment"
        />
        <VLock v-model="store.lock.environment" />
      </div>
      <SmartSelectorItem
        label="uri_label"
        :item="store.environment"
        @unset="store.environment = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
// Written with CLAUDE code
import { useStore } from '../../store/store'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

function setEnvironment(item) {
  const { uri, uri_label } = item.response_values

  store.environment = { uri, uri_label }

  if (store.isSaveAvailable && store.autosave) {
    store.saveAssertedEnvironment()
  }
}
</script>
