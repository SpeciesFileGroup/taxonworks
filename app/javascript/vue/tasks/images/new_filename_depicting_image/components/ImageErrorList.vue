<template>
  <div>
    <div
      v-for="(item, index) in list"
      :key="item.uuid"
      class="new-filename-error-row flex-separate gap-small middle"
    >
      <div class="horizontal-left-content gap-small">
        <img
          :src="item.image"
          class="new-filename-error-thumb"
        />
        <span>{{ Object.values(item.error).join('; ') }}</span>
      </div>
      <VBtn
        color="primary"
        circle
        @click="() => list.splice(index, 1)"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const list = defineModel({
  type: Array,
  required: true
})
</script>

<style scoped>
.new-filename-error-thumb {
  width: 100px;
  max-width: 100px;
  max-height: 100px;
}

.new-filename-error-row {
  border-bottom: 2px solid var(--color-border);
  padding: 1rem 0;
}

.new-filename-error-row:first-child {
  padding-top: 0;
}

.new-filename-error-row:last-child {
  border-bottom: none;
  padding-bottom: 0;
}
</style>
