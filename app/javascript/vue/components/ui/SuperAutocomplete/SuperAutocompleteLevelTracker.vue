<template>
  <div class="progress-container">
    <div
      v-for="item in levels"
      :key="item.level"
      class="progress-segment cursor-pointer"
      :title="item.description"
      :style="
        item.level === currentLevel && {
          backgroundColor: item.color
        }
      "
      @click="() => emit('select', item.level)"
    >
      {{ item.label }}
    </div>
  </div>
</template>

<script setup>
defineProps({
  currentLevel: Number,

  levels: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])
</script>

<style scoped>
.progress-container {
  display: flex;
  gap: 4px;
  justify-content: center;
  position: absolute;
  width: 100%;
  top: -4px;
  height: 4px;
  z-index: 2;
}

.progress-segment {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
  height: 4px;
  font-size: 0;
  background-color: #ddd;
  transition: background-color 0.2s ease;
}

.active {
  /*   background-color: #1f94d2; */
}

.progress-segment:hover {
  font-size: 12px;
  height: 32px;
  top: -30px;
  transition: all 0.2s ease;
}
</style>
