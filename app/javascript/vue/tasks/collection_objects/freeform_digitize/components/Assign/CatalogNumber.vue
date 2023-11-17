<template>
  <fieldset>
    <legend>Catalogue numbers</legend>
    <SmartSelector
      model="namespaces"
      :klass="COLLECTION_OBJECT"
      pin-section="Namespaces"
      pin-type="Namespace"
      v-model="store.catalogNumber.namespace"
    >
      <template #tabs-right>
        <VLock
          class="margin-small-left"
          v-model="lock.identifier"
        />
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="namespace"
      @unset="store.catalogNumber.namespace = undefined"
    />
    <div class="horizontal-left-content">
      <div class="margin-small-top margin-small-right full_width">
        <label class="display-block">Identifier</label>
        <input
          class="full_width"
          v-model="store.catalogNumber.identifier"
          type="number"
        />
      </div>
    </div>
  </fieldset>
</template>

<script setup>
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import { COLLECTION_OBJECT } from '@/constants/index'

const store = useStore()
const lock = useLockStore()
</script>
