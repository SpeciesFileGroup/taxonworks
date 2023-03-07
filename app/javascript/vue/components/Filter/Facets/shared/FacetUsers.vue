<template>
  <FacetContainer>
    <h3 class="flex-separate">
      Housekeeping
    </h3>
    <div class="field">
      <select v-model="params.user_id">
        <option
          v-for="u in usersList"
          :key="u.id"
          :value="u.user.id"
        >
          {{ u.user.name }}
        </option>
      </select>
    </div>
    <h3>Target</h3>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="item in OPTIONS"
          :key="item.value"
        >
          <label>
            <input
              :value="item.value"
              v-model="params.user_target"
              type="radio"
            >
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
    <h3>Date range</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date:</label>
        <br>
        <input
          type="date"
          class="date-input"
          v-model="params.user_date_start"
        >
      </div>
      <div class="field">
        <label>End date:</label>
        <br>
        <div class="horizontal-left-content">
          <input
            type="date"
            class="date-input"
            v-model="params.user_date_end"
          >
          <button
            type="button"
            class="button normal-input button-default margin-small-left"
            @click="setActualDateEnd"
          >
            Now
          </button>
        </div>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { ProjectMember } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Created at',
    value: 'created'
  },
  {
    label: 'Updated at',
    value: 'updated'
  }
]

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'update:modelValue',
  'onUserslist'
])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const usersList = ref([])
const startDate = computed(() => params.value.user_date_start)

watch(
  startDate,
  newVal => {
    if (!newVal) {
      params.value.user_date_end = undefined
    }
  }
)

onBeforeMount(() => {
  ProjectMember.all().then(response => {
    usersList.value = response.body
    usersList.value.unshift({ user: { name: '--none--', id: undefined } })
  })

  const urlParams = URLParamsToJSON(location.href)
  if (Object.keys(urlParams).length) {
    params.value.user_id = urlParams.user_id
    params.value.user_date_start = urlParams.user_date_start
    params.value.user_date_end = urlParams.user_date_end
    params.value.user_target = urlParams.user_target
  }
})

const setActualDateEnd = () => {
  params.value.user_date_end = new Date().toISOString().split('T')[0]
}
</script>
