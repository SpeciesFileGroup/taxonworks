<template>
  <BlockLayout :warning="!store.shape">
    <template #header>
      <h3>Shape</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <ShapePicker
          v-model="store.shape"
          class="full_width"
          @selectShape="setShape"
          label="name"
        >
          <template #tabs-right>
            <VLock
              v-model="store.lock.shape"
              class="margin-small-left"
            />
          </template>
        </ShapePicker>
      </div>
      <hr
        v-if="store.shape?.id"
        class="divisor"
      />
      <SmartSelectorItem
        label="name"
        :item="store.shape"
        @unset="store.shape = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { useStore } from '../../store/store'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import ShapePicker from '@/components/ui/SmartSelector/ShapePicker.vue'

const store = useStore()

function setShape(item) {
  store.shape = item

  if (store.isSaveAvailable && store.autosave) {
    store.saveAssertedDistribution()
  }
}
</script>
