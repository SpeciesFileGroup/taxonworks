<template>
  <FacetContainer>
    <h3>Container type</h3>
    <ul class="no_bullets">
      <li
        v-for="item in containerTypes"
        :key="item.type"
      >
        <label class="capitalize">
          <input
            type="checkbox"
            :checked="selectedTypes.includes(item.type)"
            @change="(e) => toggleType(item.type, e.target.checked)"
          />
          {{ item.name }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed, ref } from 'vue'
import { Container } from '@/routes/endpoints'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const containerTypes = ref([])

const selectedTypes = computed(() => [params.value.type || []].flat())

function toggleType(type, checked) {
  params.value.type = checked
    ? [...selectedTypes.value, type]
    : selectedTypes.value.filter((t) => t !== type)
}

Container.types().then(({ body }) => {
  containerTypes.value = body
})
</script>
