<template>
  <div>
<<<<<<< HEAD
    <h2 class="tw-section-title">Preparation</h2>
    <div class="flex-row gap-small align-start">
      <ul
        v-for="(itemsGroup, index) in chunkList"
        :key="index"
        class="no_bullets preparation-list"
      >
        <li
          v-for="type in itemsGroup"
          :key="type.id"
        >
          <label>
            <input
              type="radio"
              :value="type.id"
              v-model="collectionObject.preparation_type_id"
              name="collection-object-type"
            />
            {{ type.name }}
          </label>
        </li>
      </ul>
      <lock-component v-model="locked.collection_object.preparation_type_id" />
    </div>
=======
    <h2>Preparation</h2>
    <PreparationTypeSelector
      target="CollectionObject"
      v-model="preparationTypeId"
    >
      <template #tabs-right>
        <LockComponent v-model="locked.collection_object.preparation_type_id" />
      </template>
    </PreparationTypeSelector>
>>>>>>> development
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
