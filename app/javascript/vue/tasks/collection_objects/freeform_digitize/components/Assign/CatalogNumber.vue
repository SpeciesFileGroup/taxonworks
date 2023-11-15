<template>
  <fieldset>
    <legend>Catalogue numbers</legend>
    <div class="align-start margin-medium-top">
      <SmartSelector
        model="namespaces"
        klass="CollectionObject"
        pin-section="Namespaces"
        pin-type="Namespace"
        @selected="setValue"
      />
      <VLock
        class="margin-small-left"
        v-model="lock.identifier"
      />
    </div>
    <SmartSelectorItem
      :item="namespace"
      @unset="namespace = undefined"
    />
    <div class="horizontal-left-content">
      <div class="margin-small-top margin-small-right full_width">
        <label class="display-block">Identifier</label>
        <input
          class="full_width"
          v-model="identifier.identifier"
          type="number"
        />
      </div>
      <div class="margin-small-top margin-small-left full_width">
        <label class="display-block">End</label>
        <input
          class="full_width"
          :value="incremented"
          disabled="true"
          type="number"
        />
      </div>
    </div>
  </fieldset>
</template>

<script setup>
import { ref, watch } from 'vue'
import useLockStore from '../../store/lock.js'
import useStore from '../../store/identifier.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'

const identifier = useStore()
const lock = useLockStore()
const catalogNumber = ref(null)

watch(catalogNumber, (newVal) => {
  identifier.namespace_id = newVal?.id
})
</script>
