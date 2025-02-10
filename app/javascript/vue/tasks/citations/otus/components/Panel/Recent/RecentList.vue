<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>{{ title }}</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td
          class="cursor-pointer"
          @click="() => emit('select', item)"
        >
          <div v-html="item[label]" />
        </td>
        <td class="w-2">
          <RadialNavigator :global-id="item.globalId" />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialNavigator from '@/components/radials/navigation/radial.vue'

defineProps({
  title: {
    type: String,
    required: true
  },

  list: {
    type: Array,
    required: true
  },

  label: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
