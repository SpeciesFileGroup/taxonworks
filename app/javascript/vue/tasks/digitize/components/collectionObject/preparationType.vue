<template>
  <div>
    <h3>Preparation</h3>
    <PreparationTypeSelector
      target="CollectionObject"
      v-model="preparationTypeId"
    >
      <template #tabs-right>
        <LockComponent v-model="locked.collection_object.preparation_type_id" />
      </template>
    </PreparationTypeSelector>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { MutationNames } from '../../store/mutations/mutations.js'
import { GetterNames } from '../../store/getters/getters.js'
import LockComponent from '@/components/ui/VLock/index.vue'
import PreparationTypeSelector from '@/components/ui/SmartSelector/PreparationTypeSelector.vue'

const store = useStore()

const locked = computed({
  get: () => store.getters[GetterNames.GetLocked],
  set: (value) => store.commit(MutationNames.SetLocked, value)
})

const collectionObject = computed({
  get: () => store.getters[GetterNames.GetCollectionObject],
  set: (value) => store.commit(MutationNames.SetCollectionObject, value)
})

const preparationTypeId = computed({
  get: () => collectionObject.value.preparation_type_id,
  set: (value) => {
    collectionObject.value = {
      ...collectionObject.value,
      preparation_type_id: value || null
    }
  }
})
</script>
