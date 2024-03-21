<template>
  <div>
    <div>
      <div
        v-for="group in biocurationsGroups"
        :key="group.id"
      >
        <label>{{ group.name }}</label>
        <br />
        <template
          v-for="item in group.list"
          :key="item.id"
        >
          <VBtn
            v-if="!isInList(item.id)"
            color="primary"
            medium
            class="biocuration-toggle-button"
            @click="() => emit('add', item)"
          >
            {{ item.name }}
          </VBtn>
          <VBtn
            v-else
            medium
            class="biocuration-toggle-button"
            @click="() => emit('remove', item)"
          >
            {{ item.name }}
          </VBtn>
        </template>
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
  }
})

const emit = defineEmits(['add', 'remove'])

const list = defineModel({
  type: Array,
  default: () => []
})

function isInList(id) {
  return !!list.value.find((bio) => id === bio.biocurationClassId)
}
</script>

<style lang="scss" scoped>
.total-input {
  width: 50px;
}
.biocuration-toggle-button {
  min-width: 60px;
  border: 0px;
  margin-right: 6px;
  margin-bottom: 6px;
  border-top-left-radius: 14px;
  border-bottom-left-radius: 14px;

  &__disabled {
    opacity: 0.3;
  }
}
</style>
