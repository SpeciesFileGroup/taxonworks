<template>
  <BlockLayout :warning="!store.geographicArea">
    <template #header>
      <h3>Geographic area</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <SmartSelector
          v-model="store.geographicArea"
          class="full_width"
          model="geographic_areas"
          klass="AssertedDistribution"
          target="AssertedDistribution"
          label="name"
          :add-tabs="['map']"
          pin-section="GeographicAreas"
          pin-type="GeographicArea"
          @selected="setGeographicArea"
        >
          <template #map>
            <GeographicAreaMapPicker @select="setGeographicArea" />
          </template>
        </SmartSelector>
        <VLock
          v-model="store.lock.geographicArea"
          class="margin-small-left"
        />
      </div>
      <hr
        v-if="store.geographicArea"
        class="divisor"
      />
      <SmartSelectorItem
        label="name"
        :item="store.geographicArea"
        @unset="store.geographicArea = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { useStore } from '../../store/store'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import GeographicAreaMapPicker from '@/components/ui/SmartSelector/GeographicAreaMapPicker.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

function setGeographicArea(item) {
  store.geographicArea = item

  if (store.isSaveAvailable && store.autosave) {
    store.saveAssertedDistribution()
  }
}
</script>
