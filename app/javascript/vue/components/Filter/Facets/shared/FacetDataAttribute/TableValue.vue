<template>
  <table>
    <tr>
      <th class="full_width">Value</th>
      <th>Exact</th>
      <th />
    </tr>
    <thead></thead>
    <tbody>
      <tr v-for="(row, index) in values">
        <td>{{ row.text }}</td>
        <td>
          <input
            :checked="row.exact"
            @click="
              (e) =>
                emit('update', {
                  index,
                  value: { ...row, exact: !row.exact }
                })
            "
            type="checkbox"
          />
        </td>
        <td>
          <VBtn
            color="primary"
            circle
            @click="() => emit('remove', index)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  values: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['remove', 'update'])
</script>
