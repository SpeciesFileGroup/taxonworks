<template>
  <div class="flex-col gap-small padding-medium by-attribute-row">
    <div class="flex-separate">
      <div class="flex-col gap-small">
        <label>Field</label>
        <select
          v-model="attribute.fieldName"
          class="normal-input"
        >
          <option :value="null">Select a field</option>
          <option
            v-for="(type, name) in fieldNames"
            :key="type"
            :value="name"
          >
            {{ name }}
          </option>
        </select>
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
        <DataAttributeRowNegatorSelector v-model="attribute.negator" />
        <DataAttributeRowTypeSelector v-model="attribute.type" />
      </div>
      <div class="flex-row gap-small">
        <DataAttributeRowLogic v-model="attribute.logic" />
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

    <component
      class="full_width"
      :is="field.component"
      :value="attribute.value"
      v-bind="field.bind"
      placeholder="Type a value..."
      @input="(e) => (attribute.value = e.target.value)"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import DataAttributeRowLogic from '@/components/Filter/Facets/shared/FacetDataAttribute/DataAttributeRow/DataAttributeRowLogic.vue'
import DataAttributeRowTypeSelector from '@/components/Filter/Facets/shared/FacetDataAttribute/DataAttributeRow/DataAttributeRowType.vue'
import DataAttributeRowNegatorSelector from '@/components/Filter/Facets/shared/FacetDataAttribute/DataAttributeRow/DataAttributeRowNegator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const COMPONENT_TYPES = {
  default: {
    component: 'input',
    bind: {
      type: 'text'
    }
  },

  integer: {
    component: 'input',
    bind: {
      type: 'number'
    }
  },

  text: {
    component: 'textarea',
    bind: {
      rows: 3
    }
  }
}

const props = defineProps({
  attribute: {
    type: Object,
    required: true
  },

  fieldNames: {
    type: Object,
    required: true
  },

  removeButton: {
    type: Boolean,
    default: false
  }
})

const field = computed(() => {
  const type = props.fieldNames[props.attribute.fieldName]

  return COMPONENT_TYPES[type] || COMPONENT_TYPES.default
})

const emit = defineEmits(['remove', 'add'])
</script>

<style scoped>
.by-attribute-row {
  border-radius: var(--border-radius-medium);
  border: 1px solid var(--border-color);
}
</style>
