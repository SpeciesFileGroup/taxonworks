<template>
  <div>
    <h3>Repository</h3>
    <SmartSelector
      model="repositories"
      klass="CollectionObject"
      pin-section="Repositories"
      pin-type="Repository"
      v-model="store.repository"
      @selected="setRepository"
    >
      <template #tabs-right>
        <VLock
          class="margin-small-left"
          v-model="lock.repository"
        />
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="store.repository"
      label="name"
      @unset="setRepository"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'

const lock = useLockStore()
const store = useStore()

function setRepository(item) {
  store.repository = item
}
</script>
