<template>
  <FacetContainer>
    <div class="flex-separate middle">
      <h3>{{ title }}</h3>
      <VSwitch
        v-if="toggle"
        v-model="isPeopleView"
        :options="switchOptions"
      />
    </div>
    <div v-if="isPeopleView">
      <SmartSelector
        :autocomplete-params="{ role_type: roleType, in_project: true }"
        :klass="klass"
        model="people"
        pin-section="People"
        pin-type="People"
        label="cached"
        @selected="(person) => addPerson(person)"
      />
      <label
        data-help="If checked, filter results must match all items listed here"
      >
        <input
          v-model="params[paramAll]"
          type="checkbox"
        />
        All
      </label>
      <DisplayList
        :list="list"
        label="cached"
        :delete-warning="false"
        soft-delete
        @delete-index="(index) => removePerson(index)"
      />
    </div>
    <div v-else>
      <label class="display-block">Matches</label>
      <i class="display-block">Allows regular expressions</i>
      <input
        v-model="params.determiner_name_regex"
        class="full_width"
        type="text"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import VSwitch from '@/tasks/observation_matrices/new/components/Matrix/switch.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { People } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { onMounted, ref, watch } from 'vue'

const props = defineProps({
  paramAll: {
    type: String,
    required: true
  },

  paramPeople: {
    type: String,
    required: true
  },

  title: {
    type: String,
    default: ''
  },

  roleType: {
    type: Array,
    required: true
  },

  klass: {
    type: String,
    required: true
  },

  toggle: {
    type: Boolean,
    default: false
  }
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const emit = defineEmits(['toggle'])

const list = ref([])
const switchOptions = ref(['People', 'Name'])
const isPeopleView = ref(true)

watch(
  params,
  (newVal) => {
    if (!newVal[props.paramPeople]?.length && list.value.length) {
      list.value = []
    }
  }
)

watch(
  list,
  () => {
    params.value[props.paramPeople] = list.value.map((item) => item.id)
  },
  { deep: true }
)

watch(
  isPeopleView, (newVal) => {
    emit('toggle', newVal)
    list.value = []
    params.value.determiner_name_regex = undefined
  }
)

onMounted(() => {
  const urlParams = URLParamsToJSON(location.href)
  const peopleIds = urlParams[props.paramPeople] || []

  params.value[props.paramAll] = urlParams[props.paramAll]
  peopleIds.forEach((id) => {
    People.find(id).then(({ body }) => {
      addPerson(body)
    })
  })
})

function addPerson(person) {
  if (!list.value.find((item) => item.id === person.id)) {
    list.value.push(person)
  }
}

function removePerson(index) {
  list.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
