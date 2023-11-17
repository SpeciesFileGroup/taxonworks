<template>
  <fieldset>
    <legend>Preparation</legend>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="itemsGroup in coTypes.chunk(Math.ceil(coTypes.length / 2))"
        class="no_bullets full_width"
      >
        <li
          v-for="type in itemsGroup"
          :key="type.id"
        >
          <label>
            <input
              type="radio"
              :checked="type.id == store.collectionObject.preparationTypeId"
              :value="type.id"
              v-model="store.collectionObject.preparationTypeId"
              name="collection-object-type"
            />
            {{ type.name }}
          </label>
        </li>
      </ul>
      <VLock v-model="lock.preparation_type_id" />
    </div>
  </fieldset>
</template>

<script setup>
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'
import VLock from '@/components/ui/VLock/index.vue'
import { PreparationType } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'

const lock = useLockStore()
const store = useStore()

const coTypes = ref([])

onBeforeMount(() => {
  PreparationType.all().then((response) => {
    coTypes.value = response.body
  })
})
</script>
