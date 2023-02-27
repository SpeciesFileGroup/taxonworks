<template>
  <div class="horizontal-left-content">
    <div class="field separate-right full_width">
      <label> Value </label>
      <br />
      <input
        class="full_width"
        :type="TYPES[field.type]"
        v-model="attribute.value"
      />
    </div>
    <div class="field">
      <label> &nbsp; </label>
      <br />
      <div class="horizontal-left-content middle gap-small">
        <VBtn
          color="primary"
          medium
          @click="() => addField(attribute)"
        >
          Add
        </VBtn>
        <VBtn
          color="primary"
          medium
          @click="() => addField({ any: true })"
        >
          Any
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'

const TYPES = {
  text: 'text',
  string: 'text',
  integer: 'number',
  decimal: 'number'
}

const props = defineProps({
  field: {
    type: Object,
    required: true
  },

  any: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['add'])

const attribute = ref({
  exact: false,
  value: undefined
})

const addField = (params) => {
  emit('add', {
    param: props.field.name,
    type: props.field.type,
    ...params
  })
}
</script>
