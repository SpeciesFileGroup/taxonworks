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
import { onMounted, ref } from 'vue'
import { useHydratedFacetList, missingRecord } from '@/components/Filter/composables/useHydratedFacetList.js'

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

const SERVICES = { Person: People, Organization }

const {
  list,
  hydrate,
  add,
  remove: removeEntity
} = useHydratedFacetList({
  ids: () => [
    ...(params.value[props.paramPeople] ?? []),
    ...(params.value[props.paramOrganization] ?? [])
  ],
  write: (items) => {
    params.value[props.paramPeople] = idsOfType(items, 'Person')
    params.value[props.paramOrganization] = idsOfType(items, 'Organization')
  },
  load: ({ id, type }) =>
    SERVICES[type].find(id).then(({ body }) => makeEntity(body, type)),
  missing: ({ id, type }) => makeEntity(missingRecord(id), type),
  key: (item) => `${item.type}:${item.entity.id}`
})
const isPeopleView = ref(true)

onMounted(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value[props.paramAll] = urlParams[props.paramAll]

  hydrate([
    ...(urlParams[props.paramPeople] || []).map((id) => ({ id, type: 'Person' })),
    ...(urlParams[props.paramOrganization] || []).map((id) => ({
      id,
      type: 'Organization'
    }))
  ])
})

function idsOfType(items, type) {
  return items.filter((item) => item.type == type).map((item) => item.entity.id)
}

function makeEntity(entity, type) {
  return {
    entity,
    type,
    display: type == 'Person' ? entity.cached : entity.object_tag
  }
}

function addEntity(entity, type) {
  add(makeEntity(entity, type))
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
