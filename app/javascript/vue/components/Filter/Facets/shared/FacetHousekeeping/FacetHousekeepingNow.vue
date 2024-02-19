<template>
  <div class="relative">
    <VBtn
      color="primary"
      medium
      @click="() => (isModalVisible = true)"
    >
      Now
    </VBtn>
    <VPopup
      class="popup-now"
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <div class="horizontal-left-content gap-medium">
        <VBtn
          v-for="(item, key) in DATE_BUTTONS"
          :key="key"
          color="primary"
          medium
          @click="
            () => {
              emit('select', setTimeFrom(item))
              isModalVisible = false
            }
          "
        >
          {{ key }}
        </VBtn>
      </div>
    </VPopup>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VPopup from '@/components/ui/Popup/Popup.vue'

const DATE_BUTTONS = {
  Today: [0, 0, 0],
  Yesterday: [0, 0, 1],
  Week: [0, 0, 7],
  Month: [0, 1, 0],
  Year: [1, 0, 0]
}

const isModalVisible = ref(false)

const emit = defineEmits(['select'])

function setTimeFrom([year, month, day]) {
  const date = new Date()

  date.setFullYear(date.getFullYear() - year)
  date.setMonth(date.getMonth() - month)
  date.setDate(date.getDate() - day)

  return date
}
</script>

<style scoped>
.popup-now {
  right: 0;
  margin-right: -1em;
}
</style>
