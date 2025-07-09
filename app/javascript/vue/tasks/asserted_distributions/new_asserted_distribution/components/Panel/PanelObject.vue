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
import { BiologicalAssociation, Otu } from '@/routes/endpoints'
import { useStore } from '../../store/store'
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

const paramToService = {
  otu_id: Otu,
  biological_association_id: BiologicalAssociation
}

onBeforeMount(() => {
  const parameters = Object.keys(paramToService)
  const urlParams = new URLSearchParams(window.location.search)
  const idParam = parameters.find((param) => /^\d+$/.test(urlParams.get(param)))

  if (!idParam) return

  const id = urlParams.get(idParam)

  paramToService[idParam]
    .find(id)
    .then(({ body }) => {
      store.object = body
    })
    .catch(() => {})
})
</script>

<style scoped>
li {
  margin-bottom: 8px;
}
</style>
