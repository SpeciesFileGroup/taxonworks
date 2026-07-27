<template>
  <table class="vue-table">
    <thead>
      <tr>
        <th>Citation</th>
        <th>
          <div class="horizontal-right-content">
            <VLock
              v-if="lock !== undefined"
              class="margin-small-left"
              v-model="lockButton"
            />
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.uuid"
      >
        <td>
          <span v-html="item.label" />
        </td>
        <td>
          <div class="horizontal-right-content gap-small">
            <RadialAnnotator
              v-if="item.global_id"
              :global-id="item.global_id"
            />

            <VBtn
              icon
              variant="tonal"
              color="primary"
              @click="emit('edit', item)"
            >
              <IconPencil class="w-4 h-4" />
            </VBtn>

            <VBtn
              icon
              variant="tonal"
              color="primary"
              @click="emit('delete', item)"
            >
              <IconTrash class="w-4 h-4" />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VLock from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPencil from '@/components/Icon/IconPencil.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  lock: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:lock', 'edit', 'delete'])

const lockButton = computed({
  get: () => props.lock,
  set: (value) => emit('update:lock', value)
})
</script>
