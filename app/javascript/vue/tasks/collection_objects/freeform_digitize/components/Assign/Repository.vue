<template>
  <fieldset>
    <legend>Repository</legend>
    <div class="horizontal-left-content align-start">
      <SmartSelector
        model="repositories"
        klass="CollectionObject"
        pin-section="Repositories"
        pin-type="Repository"
        v-model="repository"
        @selected="setRepository"
      />
      <VLock
        class="margin-small-left"
        v-model="lock.repository_id"
      />
    </div>
    <SmartSelectorItem
      :item="repository"
      label="name"
      @unset="setRepository"
    />
  </fieldset>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'

const lock = useLockStore()
const store = useStore()
const repository = ref(null)

function setRepository(item) {
  repository.value = item
  store.collectionObject.repository_id = item?.id
}
</script>
