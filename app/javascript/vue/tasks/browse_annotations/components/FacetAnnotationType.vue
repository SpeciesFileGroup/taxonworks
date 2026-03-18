<template>
  <FacetContainer>
    <h3>Annotation type</h3>
    <VSpinner
      v-if="isLoading"
      legend="Loading types..."
    />
    <ul class="no_bullets">
      <li
        v-for="(item, key) in typesList"
        :key="key"
      >
        <label>
          <input
            :checked="modelValue === key"
            :disabled="item.total == 0"
            name="annotation-type"
            type="radio"
            :value="key"
            @click="item.total == 0 ? false : selectType(key)"
          />
          <span v-html="item.label" />
          <span class="subtle">
            <template v-if="item.total == 0">(no records)</template>
            <template v-else>{{ item.total }} records</template>
          </span>
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import AjaxCall from '@/helpers/ajaxCall'

const props = defineProps({
  modelValue: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'types-loaded'])

const typesList = ref({})
const isLoading = ref(true)

onBeforeMount(() => {
  AjaxCall('get', '/annotations/types').then((response) => {
    typesList.value = response.body.types
    isLoading.value = false
    emit('types-loaded', typesList.value)
  })
})

function selectType(typeKey) {
  emit('update:modelValue', typeKey)
}
</script>
