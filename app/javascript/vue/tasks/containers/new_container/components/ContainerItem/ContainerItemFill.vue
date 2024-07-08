<template>
  <VBtn
    color="primary"
    medium
    :disabled="disabled"
    @click="() => (isModalVisible = true)"
  >
    Fill container
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Fill container</h3>
    </template>
    <template #body>
      <label>
        Defines the incremental position that will be used to fill the container
      </label>
      <ul>
        <li
          v-for="value in DIRECTIONS"
          :key="value"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="direction"
            />
            {{ value.split('').join(' → ') }}
          </label>
        </li>
      </ul>

      <VBtn
        color="primary"
        medium
        @click="
          store.fillContainer(list, {
            override,
            direction: direction.split('').reverse()
          })
        "
      >
        Fill
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { useContainerStore } from '../../store'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const DIRECTIONS = ['xyz', 'xzy', 'yxz', 'yzx', 'zyx', 'zxy']

defineProps({
  disabled: {
    type: Boolean,
    default: false
  },

  list: {
    type: Array,
    default: () => []
  }
})

const store = useContainerStore()
const direction = ref('xyz')
const override = ref(false)

const isModalVisible = ref(false)
</script>
