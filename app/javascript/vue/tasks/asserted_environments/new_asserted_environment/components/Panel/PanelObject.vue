<template>
  <BlockLayout :warning="!store.object">
    <template #header>
      <h3>Object</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <AssertedEnvironmentObjectPicker
          v-model="store.object"
          class="full_width"
          @select-object="broadcastObject"
        >
          <template #tabs-right>
            <VBroadcast v-model="isBroadcastActive" />
            <VLock
              v-model="store.lock.object"
              class="margin-small-left"
            />
          </template>
        </AssertedEnvironmentObjectPicker>
      </div>
      <SmartSelectorItem
        label="object_tag"
        :item="store.object"
        @unset="store.object = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
// Written with CLAUDE code
import { onBeforeMount, ref } from 'vue'
import { useBroadcastChannel } from '@/composables'
import { CollectingEvent, Gazetteer, Otu } from '@/routes/endpoints'
import { COLLECTING_EVENT, GAZETTEER, OTU } from '@/constants'
import { useStore } from '../../store/store'
import AssertedEnvironmentObjectPicker from '@/components/ui/SmartSelector/AssertedEnvironmentObjectPicker.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import VBroadcast from '@/components/ui/VBroadcast/VBroadcast.vue'

const store = useStore()
const isBroadcastActive = ref(false)

const { post } = useBroadcastChannel({
  name: 'otuObject',
  onMessage({ data }) {
    if (isBroadcastActive.value && data.objectType === OTU) {
      store.object = data
    }
  }
})

const paramToService = {
  otu_id: { service: Otu, objectType: OTU },
  collecting_event_id: { service: CollectingEvent, objectType: COLLECTING_EVENT },
  gazetteer_id: { service: Gazetteer, objectType: GAZETTEER }
}

function broadcastObject(obj) {
  if (isBroadcastActive.value && obj.objectType === OTU) {
    post(obj)
  }
}

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const idParam = Object.keys(paramToService).find((param) =>
    /^\d+$/.test(urlParams.get(param))
  )

  if (!idParam) return

  const { service, objectType } = paramToService[idParam]

  service
    .find(urlParams.get(idParam))
    .then(({ body }) => {
      store.object = { ...body, objectType }
    })
    .catch(() => {})
})
</script>
