<template>
  <fieldset>
    <legend>Collecting Event</legend>
    <div class="align-start">
      <SmartSelector
        model="collecting_events"
        klass="CollectingEvent"
        pin-section="CollectingEvents"
        pin-type="CollectingEvent"
        @selected="setValue"
      />
      <VLock
        class="margin-small-left"
        v-model="lock.collecting_event_id"
      />
    </div>
    <SmartSelectorItem
      :item="collectingEvent"
      @unset="collectingEvent = undefined"
    />
  </fieldset>
</template>

<script setup>
import { ref, watch } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'

const lock = useLockStore()
const store = useStore()
const collectingEvent = ref(null)

watch(collectingEvent, (newVal) => {
  collectingEvent.value = newVal
  store.collectionObject.collecting_event_id = newVal?.id
})
</script>
