<template>
  <table class="margin-medium-bottom table-striped full_width">
    <thead>
      <tr>
        <th v-if="showPredicate">Predicate</th>
        <th v-if="showValue">Value</th>
        <th v-if="showExact" class="w-2">Exact</th>
        <th class="w-2"></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="predicate in predicates"
        :key="predicate.uuid"
      >
        <td
          v-if="showPredicate"
          class="column-predicate ellipsis"
          :title="predicate.name || 'Any'"
          v-html="predicate.name || '<i>Any</i>'"
        />
        <td
          v-if="showValue"
          class="column-text ellipsis"
          :title="predicate.text"
          v-text="predicate.text"
        />
        <td v-if="showExact">
          <label>
            <input
              :checked="predicate.exact"
              @click="
                () =>
                  emit('update', { ...predicate, exact: !predicate.exact })
              "
              type="checkbox"
            />
          </label>
        </td>
        <td>
          <VBtn
            color="primary"
            circle
            @click="() => emit('remove', predicate)"
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
  },
  showPredicate: {
    type: Boolean,
    default: true
  },
  showValue: {
    type: Boolean,
    default: true
  },
  showExact: {
    type: Boolean,
    default: true
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
