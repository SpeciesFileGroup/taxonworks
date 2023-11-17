<template>
  <fieldset>
    <legend>Catalogue numbers</legend>
    <div class="align-start margin-medium-top">
      <SmartSelector
        model="namespaces"
        klass="CollectionObject"
        pin-section="Namespaces"
        pin-type="Namespace"
        v-model="store.catalogNumber.namespace"
      />
      <VLock
        class="margin-small-left"
        v-model="lock.identifier"
      />
    </div>
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

const store = useStore()
const lock = useLockStore()
</script>
