<template>
  <BlockLayout :warning="!store.otu">
    <template #header>
      <h3>Otu</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <SmartSelector
          v-model="store.otu"
          class="full_width"
          model="otus"
          klass="AssertedDistribution"
          target="AssertedDistribution"
          pin-section="Otus"
          pin-type="Otu"
          search
          :autocomplete="false"
          otu-picker
        >
          <template #tabs-right>
            <VLock
              v-model="store.lock.otu"
              class="margin-small-left"
            />
          </template>
        </SmartSelector>
      </div>
      <hr
        v-if="store.otu"
        class="divisor"
      />
      <SmartSelectorItem
        label="object_tag"
        :item="store.otu"
        @unset="store.otu = null"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { Otu } from '@/routes/endpoints'
import { useStore } from '../../store/store'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const otuId = urlParams.get('otu_id')

  if (!/^\d+$/.test(otuId)) return

  Otu.find(otuId)
    .then((response) => {
      store.otu = response.body
    })
    .catch(() => {})
})
</script>

<style scoped>
li {
  margin-bottom: 8px;
}
</style>
