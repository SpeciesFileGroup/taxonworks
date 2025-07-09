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
            :class="[
              'biocuration-toggle-button',
              disabled && 'biocuration-toggle-button__disabled'
            ]"
            @click="() => !disabled && emit('add', item)"
          >
            {{ item.name }}
          </VBtn>
          <VBtn
            v-else
            medium
            :class="[
              'biocuration-toggle-button',
              disabled && 'biocuration-toggle-button__disabled'
            ]"
            @click="() => !disabled && emit('remove', item)"
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
.biocuration-toggle-button {
  min-width: 60px;
  border: 0px;
  margin-right: 6px;
  margin-bottom: 6px;
  border-top-left-radius: 14px;
  border-bottom-left-radius: 14px;

  &__disabled {
    opacity: 0.5;
  }
}
</style>
