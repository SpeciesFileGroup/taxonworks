<template>
  <BlockLayout :warning="!selected">
    <template #header>
      <h3>{{ title }}</h3>
    </template>
    <template #body>
      <div>
        <VSwitch
          class="margin-small-bottom"
          :options="Object.keys(TABS)"
          v-model="currentTab"
        />
        <SmartSelector
          class="full_width"
          v-model="selected"
          :model="TABS[currentTab]"
          :klass="BIOLOGICAL_ASSOCIATION"
          :target="BIOLOGICAL_ASSOCIATION"
          :pin-section="currentTab"
          :otu-picker="currentTab === OTU"
          :pin-type="currentTab"
          @selected="broadcastObject"
        >
          <template #tabs-right>
            <VBroadcast v-model="isBroadcastActive" />
            <VLock v-model="lock" />
          </template>
        </SmartSelector>
      </div>
      <hr
        v-if="selected"
        class="divisor"
      />
      <SmartSelectorItem
        :item="selected"
        @unset="() => (selected = null)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import {
  BIOLOGICAL_ASSOCIATION,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import VLock from '@/components/ui/VLock/index.vue'
import { useBroadcastChannel } from '@/composables'
import VBroadcast from '@/components/ui/VBroadcast/VBroadcast.vue'

const TABS = {
  [OTU]: 'otus',
  [COLLECTION_OBJECT]: 'collection_objects',
  [FIELD_OCCURRENCE]: 'field_occurrences'
}

defineProps({
  title: {
    type: String,
    required: true
  }
})

const { post } = useBroadcastChannel({
  name: 'otuObject',
  onMessage({ data }) {
    if (isBroadcastActive.value) {
      selected.value = data
    }
  }
})

const currentTab = ref(OTU)
const isBroadcastActive = ref(false)

const selected = defineModel({
  type: Object,
  default: null
})

const lock = defineModel('lock', {
  type: Boolean,
  default: false
})

function broadcastObject(otu) {
  if (isBroadcastActive.value) {
    post(otu)
  }
}
</script>
