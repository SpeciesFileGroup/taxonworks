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
import {
  BiologicalAssociation,
  BiologicalAssociationsGraph,
  Conveyance,
  Depiction,
  Observation,
  Otu
} from '@/routes/endpoints'
import { OTU } from '@/constants'
import { useStore } from '../../store/store'
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

const paramToService = {
  otu_id: Otu,
  biological_association_id: BiologicalAssociation,
  observation_id: Observation,
  biological_associations_graph_id: BiologicalAssociationsGraph,
  conveyance_id: Conveyance,
  depiction_id: Depiction
}

function isTypeAllowed(obj) {
  const keys = Object.keys(obj)
  const attrType = keys.find((k) => k.endsWith('_object_type'))

  return !attrType || obj[attrType] === OTU
}

function setObject(obj) {
  if (isTypeAllowed(obj)) {
    store.object = obj
  } else {
    TW.workbench.alert.create('Object type is not supported.', 'error')
  }
}

onBeforeMount(() => {
  const parameters = Object.keys(paramToService)
  const urlParams = new URLSearchParams(window.location.search)
  const idParam = parameters.find((param) => /^\d+$/.test(urlParams.get(param)))

  if (!idParam) return

  const id = urlParams.get(idParam)

  paramToService[idParam]
    .find(id)
    .then(({ body }) => setObject(body))
    .catch(() => {})
})
</script>

<style scoped>
li {
  margin-bottom: 8px;
}
</style>
