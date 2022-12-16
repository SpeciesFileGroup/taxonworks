<template>
  <div>
    <VModal
      v-if="showModal"
      @close="showModal = false"
    >
      <template #header>
        <h3>Show scored character states</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="characterState in descriptor.characterStates"
            :key="characterState.id"
          >
            <label>
              <input
                v-model="filterCharacterStates"
                :value="characterState.id"
                type="checkbox"
              >
              {{ characterState.name }}
            </label>
          </li>
        </ul>
      </template>
    </VModal>
    <VBtn
      color="primary"
      medium
      @click="showModal = true"
    >
      Show scored character states
    </VBtn>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed, ref } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()
const showModal = ref(false)
const filterCharacterStates = computed({
  get: () => store.getters[GetterNames.GetDisplayScoredCharacterStates],
  set: value => store.commit(MutationNames.SetDisplayScoredCharacterStates, value)
})

const descriptor = computed(() => store.getters[GetterNames.GetDescriptor])

</script>
