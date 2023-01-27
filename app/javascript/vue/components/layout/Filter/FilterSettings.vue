<template>
  <VBtn
    color="primary"
    class="circle-button"
    circle
    @click="isModalVisible = !isModalVisible"
  >
    <VIcon
      name="eye"
      x-small
    />
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Layout</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <slot name="preferences-first" />
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter"
            />
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeUrl"
            />
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeList"
            />
            Show list
          </label>
        </li>
        <slot name="preferences-last" />
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  filter: {
    type: Boolean,
    default: undefined
  },

  url: {
    type: Boolean,
    default: undefined
  },

  list: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:filter', 'update:url', 'update:list'])

const isModalVisible = ref(false)

const activeFilter = computed({
  get: () => props.filter,
  set: (value) => emit('update:filter', value)
})

const activeUrl = computed({
  get: () => props.url,
  set: (value) => emit('update:url', value)
})

const activeList = computed({
  get: () => props.list,
  set: (value) => emit('update:list', value)
})
</script>
