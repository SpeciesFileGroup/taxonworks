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
          :pin-type="currentTab"
        >
          <template #tabs-right>
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
import { BIOLOGICAL_ASSOCIATION, COLLECTION_OBJECT, OTU } from '@/constants'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import VLock from '@/components/ui/VLock/index.vue'

const TABS = {
  [OTU]: 'otus',
  [COLLECTION_OBJECT]: 'collection_objects'
}

defineProps({
  title: {
    type: String,
    required: true
  }
})

const currentTab = ref(OTU)

const selected = defineModel({
  type: Object,
  default: null
})

const lock = defineModel('lock', {
  type: Boolean,
  default: false
})
</script>
