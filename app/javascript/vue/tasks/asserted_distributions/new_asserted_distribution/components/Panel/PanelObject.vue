<template>
  <BlockLayout :warning="!store.object">
    <template #header>
      <h3>Object</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <AssertedDistributionObjectPicker
          v-model="store.object"
          class="full_width"
        >
          <template #tabs-right>
            <VLock
              v-model="store.lock.object"
              class="margin-small-left"
            />
          </template>
        </AssertedDistributionObjectPicker>
      </div>
      <hr
        v-if="store.otu"
        class="divisor"
      />
      <SmartSelectorItem
        label="object_tag"
        :item="store.object"
        @unset="store.object = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { Otu } from '@/routes/endpoints'
import { useStore } from '../../store/store'
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

onBeforeMount(() => {
  // Handle other non-otu types as needed (currently no other users).
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')

  if (!/^\d+$/.test(otuId)) return

  Otu.find(otuId)
    .then((response) => {
      store.object = response.body
    })
    .catch(() => {})
})
</script>

<style scoped>
li {
  margin-bottom: 8px;
}
</style>
