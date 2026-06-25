<template>
  <div>
    <div class="flex-col gap-small">
      <div
        v-for="group in biocurationsGroups"
        :key="group.id"
      >
        <label>{{ group.name }}</label>
        <br />
        <div class="biocuration-toggle-group">
          <template
            v-for="item in group.list"
            :key="item.id"
          >
            <VBtn
              v-if="!isInList(item.id)"
              variant="ghost"
              bordered
              medium
              :class="[
                'biocuration-toggle__option',
                disabled && 'biocuration-toggle-button__disabled'
              ]"
              @click="() => !disabled && emit('add', item)"
            >
              {{ item.name }}
            </VBtn>
            <VBtn
              v-else
              color="primary"
              variant="tonal"
              medium
              :class="[disabled && 'biocuration-toggle-button__disabled']"
              @click="() => !disabled && emit('remove', item)"
            >
              {{ item.name }}
            </VBtn>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  biocurationsGroups: {
    type: Array,
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['add', 'remove'])

const list = defineModel({
  type: Array,
  default: () => []
})

function isInList(id) {
  return !!list.value.find(
    (bio) => id === bio.biocurationClassId && !bio._destroy
  )
}
</script>

<style lang="scss" scoped>
.total-input {
  width: 50px;
}

.biocuration-toggle-group {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-xxs);
  width: fit-content;
  max-width: 100%;
  padding: var(--spacing-xxs);
  border-radius: var(--border-radius-medium);
  background-color: var(--bg-color);
}

.biocuration-toggle__option {
  color: var(--text-muted-color);
}

.biocuration-toggle-button__disabled {
  opacity: 0.5;
}
</style>
