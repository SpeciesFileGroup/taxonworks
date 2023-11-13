<template>
  <table class="margin-medium-bottom table-striped">
    <thead>
      <tr>
        <th>Predicate</th>
        <th>Value</th>
        <th>Exact/Any</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(predicate, index) in predicates"
        :key="predicate.id"
      >
        <td>{{ predicate.name }}</td>
        <td>{{ predicate.text }}</td>
        <td>
          <span v-if="predicate.any">Any</span>
          <span v-else-if="!predicate.text.length">Empty</span>
          <label v-else>
            <input
              :checked="predicate.exact"
              @click="
                (e) =>
                  emit('update', {
                    index,
                    predicate: { ...predicate, exact: !predicate.exact }
                  })
              "
              type="checkbox"
            />
          </label>
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
  predicates: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['remove', 'update'])
</script>
