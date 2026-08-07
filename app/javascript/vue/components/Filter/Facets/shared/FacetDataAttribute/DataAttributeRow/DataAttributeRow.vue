<template>
  <div class="flex-col gap-small padding-medium data-attribute-row">
    <div class="flex-separate">
      <div>
        <DataAttributeRowPredicateSelector
          :predicates="predicates"
          v-model="dataAttribute.predicate"
        />
      </div>
      <VBtn
        v-if="removeButton"
        color="primary"
        circle
        @click="() => emit('remove')"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>

    <div class="flex-separate middle">
      <div class="flex-row gap-small">
        <DataAttributeRowNegatorSelector v-model="dataAttribute.negator" />
        <DataAttributeRowTypeSelector v-model="dataAttribute.type" />
      </div>
      <div class="flex-row gap-small">
        <DataAttributeRowLogic v-model="dataAttribute.logic" />
        <VBtn
          color="primary"
          circle
          @click="() => emit('add')"
        >
          <VIcon
            name="plus"
            x-small
          />
        </VBtn>
      </div>
    </div>
    <textarea
      class="full_width"
      rows="3"
      :placeholder="!isValueDisabled ? 'Type a value...' : 'Value'"
      :disabled="isValueDisabled"
      v-model="dataAttribute.value"
    ></textarea>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue'
import DataAttributeRowLogic from './DataAttributeRowLogic.vue'
import DataAttributeRowTypeSelector from './DataAttributeRowType.vue'
import DataAttributeRowNegatorSelector from './DataAttributeRowNegator.vue'
import DataAttributeRowPredicateSelector from './DataAttributeRowPredicate.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const DISABLED_VALUE_ON = ['any', 'no']

const props = defineProps({
  dataAttribute: {
    type: Object,
    required: true
  },

  removeButton: {
    type: Boolean,
    default: false
  },

  predicates: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['remove', 'add'])

const isValueDisabled = computed(() =>
  DISABLED_VALUE_ON.includes(props.dataAttribute.type)
)

watch(isValueDisabled, (newVal) => {
  if (newVal) {
    props.dataAttribute.value = ''
  }
})
</script>

<style scoped>
.data-attribute-row {
  border-radius: var(--border-radius-medium);
  border: 1px solid var(--border-color);
}
</style>
