<template>
  <table class="margin-medium-bottom table-striped">
    <thead>
      <tr>
        <th>Predicate</th>
        <th>Value</th>
        <th class="w-2">Exact</th>
        <th class="w-2"></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(predicate, index) in predicates"
        :key="predicate.uuid"
      >
        <td
          class="column-predicate ellipsis"
          :title="predicate.name || 'Any'"
          v-html="predicate.name || '<i>Any</i>'"
        />
        <td
          class="column-text ellipsis"
          :title="predicate.text"
          v-text="predicate.text"
        />
        <td>
          <span v-if="predicate.any">Any</span>
          <span v-else-if="!predicate.text?.length">W/O</span>
          <label v-else>
            <input
              :checked="predicate.exact"
              @click="
                () =>
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

<style scoped>
.column-predicate {
  max-width: 130px;
}
.column-text {
  max-width: 100px;
}
</style>
