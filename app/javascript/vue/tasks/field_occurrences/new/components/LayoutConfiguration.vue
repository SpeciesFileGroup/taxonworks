<template>
  <VBtn
    color="primary"
    medium
    @click="() => (isModalVisible = true)"
  >
    Layout settings
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="handleClose"
  >
    <template #header> Layout Configuration </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="({ title }, key) in VueComponents"
          :key="key"
        >
          <label>
            <input
              type="checkbox"
              :checked="!list.includes(key)"
              @change="(e) => handleToggle(key, e.target.checked)"
            />
            {{ title }}
          </label>
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VueComponents from '../constants/components'

const props = defineProps({
  hidden: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update'])

const list = ref([])
const isModalVisible = ref(false)

function handleClose() {
  isModalVisible.value = false
  emit('update', list.value)
}

function handleToggle(key, checked) {
  list.value = checked
    ? list.value.filter((c) => c !== key)
    : [...list.value, key]
}

watch(
  () => props.hidden,
  (newVal) => {
    list.value = newVal
  },
  { immediate: true }
)
</script>
