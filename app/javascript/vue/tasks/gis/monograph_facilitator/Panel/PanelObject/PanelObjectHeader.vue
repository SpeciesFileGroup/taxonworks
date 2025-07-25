<template>
  <table class="full_width">
    <thead>
      <tr>
        <th class="w-2">
          <input
            type="checkbox"
            v-model="toggleSelection"
          />
        </th>
        <th />
        <th class="w-2">
          <VIcon
            class="cursor-pointer"
            :name="toggleHide ? 'hide' : 'show'"
            small
            @click="() => (toggleHide = !toggleHide)"
          />
        </th>
      </tr>
    </thead>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import useStore from '../../store/store.js'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useStore()

const toggleSelection = computed({
  get: () => store.objects.every((o) => store.selectedIds.includes(o.id)),
  set: (value) => {
    store.selectedIds = value ? store.objects.map((o) => o.id) : []
  }
})

const toggleHide = computed({
  get: () => store.objects.every((o) => store.hiddenIds.includes(o.id)),
  set: (value) => {
    store.hiddenIds = value ? store.objects.map((o) => o.id) : []
  }
})
</script>
