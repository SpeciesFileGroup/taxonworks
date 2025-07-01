<template>
  <FacetContainer>
    <div class="flex-separate middle">
      <h3>{{ title }}</h3>
      <VSwitch
        v-model="isPeopleView"
        :options="['People', 'Organizations']"
      />
    </div>
    <div>
      <SmartSelector
        v-if="isPeopleView"
        :autocomplete-params="{ role_type: roleType, in_project: true }"
        :klass="klass"
        model="people"
        pin-section="People"
        pin-type="People"
        label="cached"
        placeholder="Search for a person"
        @selected="(person) => addEntity(person, 'Person')"
      />

      <SmartSelector
        v-else
        :autocomplete-params="{ role_type: roleType }"
        :klass="klass"
        model="organizations"
        pin-section="Organization"
        pin-type="Organization"
        label="cached"
        placeholder="Search for an organization"
        @selected="(organization) => addEntity(organization, 'Organization')"
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
        label="display"
        :delete-warning="false"
        soft-delete
        @delete-index="(index) => removeEntity(index)"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import VSwitch from '@/tasks/observation_matrices/new/components/Matrix/switch.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { Organization, People } from '@/routes/endpoints'
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

  paramOrganization: {
    type: String,
    required: false
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
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const list = ref([])
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
    params.value[props.paramPeople] = list.value
      .filter((item) => item.type == 'Person')
      .map((item) => item.entity.id)

    params.value[props.paramOrganization] = list.value
      .filter((item) => item.type == 'Organization')
      .map((item) => item.entity.id)
  },
  { deep: true }
)

onMounted(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value[props.paramAll] = urlParams[props.paramAll]

  const peopleIds = urlParams[props.paramPeople] || []
  peopleIds.forEach((id) => {
    People.find(id).then(({ body }) => {
      addEntity(body, 'Person')
    })
  })

  const organizationIds = urlParams[props.paramOrganization] || []
  organizationIds.forEach((id) => {
    Organization.find(id).then(({ body }) => {
      addEntity(body, 'Organization')
    })
  })
})

function addEntity(entity, type) {
  if (!list.value.find((item) => item.id === entity.id && item.type == type)) {
    list.value.push({
      entity,
      type,
      display: type == 'Person' ? entity.cached : entity.object_tag,
    })
  }
}

function removeEntity(index) {
  list.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
