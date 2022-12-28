<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in roleTypes"
        :key="key"
      >
        <label>
          <input
            type="checkbox"
            :value="key"
            v-model="selectedRoles"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, ref } from 'vue'
import { People } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const selectedRoles = computed({
  get: () => props.modelValue[props.param] || [],
  set: value => {
    params.value[props.param] = value
  }
})

const roleTypes = ref([])

People.roleTypes().then(response => {
  roleTypes.value = response.body
})

const { [props.param]: urlParam = [] } = URLParamsToJSON(location.href)

selectedRoles.value = urlParam
</script>
