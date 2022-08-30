<template>
  <div class="field">
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
            v-model="selected[param]"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { People } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Array,
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
const selected = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const roleTypes = ref([])

People.roleTypes().then(response => {
  roleTypes.value = response.body
})

const { [props.param]: urlParam = [] } = URLParamsToJSON(location.href)

selected.value[props.param] = urlParam
</script>
