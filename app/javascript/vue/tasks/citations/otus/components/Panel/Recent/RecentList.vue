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
        <td>
          <div v-html="item[label]" />
        </td>
        <td class="w-2">
          <div class="horizontal-right-content middle gap-small">
            <VBtn
              color="primary"
              circle
              title="Click to select"
              @click="() => emit('select', item)"
            >
              <VIcon
                name="pointer"
                title="Click to select"
                x-small
              />
            </VBtn>
            <RadialNavigator :global-id="item.globalId" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
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
