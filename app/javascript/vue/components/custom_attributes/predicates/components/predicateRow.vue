<template>
  <div class="field">
    <label v-html="predicateObject.object_tag" />
    <autocomplete
      v-model="dataAttribute.value"
      :url="`/data_attributes/value_autocomplete`"
      :add-params="{
        predicate_id: predicateObject.id
      }"
      param="term"
      @get-item="
        (value) => {
          dataAttribute.value = value
          updatePredicate()
        }
      "
      @change="updatePredicate"
    />
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete'
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE } from '@/constants'
import { watch, ref } from 'vue'

const props = defineProps({
  predicateObject: {
    type: Object,
    required: true
  },

  objectId: {
    type: [String, Number],
    default: undefined
  },

  objectType: {
    type: String,
    required: true
  },

  existing: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['onUpdate'])

const dataAttribute = ref(makeDataAttribute())

watch(
  () => props.existing,
  (newVal) => {
    dataAttribute.value = newVal || makeDataAttribute()
  },
  {
    immediate: true,
    deep: true
  }
)
watch(
  () => props.objectId,
  (newVal) => {
    if (!newVal) {
      dataAttribute.value.value = undefined
    }
  }
)

function makeDataAttribute() {
  return {
    type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE,
    controlled_vocabulary_term_id: props.predicateObject.id,
    attribute_subject_id: props.objectId,
    attribute_subject_type: props.objectType,
    value: undefined
  }
}

function updatePredicate() {
  const value = dataAttribute.value?.value?.trim()
  const id = dataAttribute.value.id

  if (!value) {
    if (id) {
      emit('onUpdate', {
        id,
        controlled_vocabulary_term_id: props.predicateObject.id,
        _destroy: true
      })
    }
  } else {
    emit('onUpdate', dataAttribute.value)
  }
}
</script>
