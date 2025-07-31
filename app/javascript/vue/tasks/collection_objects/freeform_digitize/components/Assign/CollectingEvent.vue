<template>
  <div>
    <h3>Collecting Event</h3>
    <SmartSelector
      model="collecting_events"
      klass="CollectingEvent"
      pin-section="CollectingEvents"
      pin-type="CollectingEvent"
      @selected="setCollectingEvent"
    >
      <template #tabs-right>
        <VLock
          class="margin-small-left"
          v-model="lock.collectingEvent"
        />
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="store.collectingEvent"
      @unset="setCollectingEvent"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'

const lock = useLockStore()
const store = useStore()

function setCollectingEvent(item) {
  store.collectingEvent = item
}
</script>
