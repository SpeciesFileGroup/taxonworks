<template>
  <div>
    <template v-if="createForm">
      <div v-if="organization">
        <OrganizationPicker
          :show-new-button="showCreateControls"
          @select="addOrganization"
        />
      </div>

      <div
        v-else
        class="horizontal-left-content align-start"
      >
        <div class="horizontal-left-content">
          <autocomplete
            ref="autocompleteRef"
            :autofocus="autofocus"
            class="separate-right"
            url="/people/autocomplete"
            label="label_html"
            display="label"
            min="2"
            clear-after
            :add-params="{
              project_id: true,
              role_type: roleTypes
            }"
            placeholder="Family name, given name"
            param="term"
            @get-input="setInput"
            @get-item="_addPersonById"
          />
          <DefaultPin
            type="People"
            section="People"
            @get-item="_addPersonById"
          />
        </div>
        <div
          class="flex-wrap-column separate-left"
          v-if="showCreateControls && searchPerson.length > 0"
        >
          <div class="flex-wrap-row gap-xsmall">
            <input
              class="normal-input"
              disabled
              :value="newNamePerson"
            />
            <VBtn
              type="button"
              color="create"
              medium
              @click="createPerson()"
            >
              Add new
            </VBtn>
            <VBtn
              type="button"
              color="primary"
              medium
              @click="switchName(newNamePerson)"
            >
              Switch
            </VBtn>
            <VBtn
              type="button"
              color="primary"
              medium
              @click="expandPerson = !expandPerson"
            >
              Expand
            </VBtn>
          </div>
          <hr class="divisor" />
          <div
            class="flex-wrap-column"
            v-if="expandPerson"
          >
            <div class="field label-above">
              <label>Given name</label>
              <input
                v-model="person_attributes.first_name"
                type="text"
              />
            </div>
            <div class="field label-above">
              <label>Family name prefix</label>
              <input
                v-model="person_attributes.prefix"
                type="text"
              />
            </div>
            <div class="field label-above">
              <label>Family name</label>
              <input
                v-model="person_attributes.last_name"
                type="text"
              />
            </div>
            <div class="field label-above">
              <label>Family name suffix</label>
              <input
                v-model="person_attributes.suffix"
                type="text"
              />
            </div>
          </div>
        </div>
      </div>
    </template>

    <draggable
      v-if="!hiddenList"
      class="table-entrys-list"
      element="ul"
      v-model="roles_attributes"
      item-key="id"
      @end="onSortable"
    >
      <template #item="{ element, index }">
        <li
          class="list-complete-item flex-separate middle cursor-grab"
          v-if="!element._destroy && filterRole(element)"
        >
          <a
            v-if="
              element.hasOwnProperty('person_id') ||
              element.hasOwnProperty('person')
            "
            :href="getUrl(element)"
            target="_blank"
            v-html="getLabel(element)"
          />
          <span
            v-else
            v-html="getLabel(element)"
          />
          <div class="flex-row gap-small middle">
            <RadialAnnotator :global-id="getGlobalId(element)" />
            <RadialNavigator
              :global-id="getGlobalId(element)"
              :redirect="false"
              @delete="() => removeFromList(index)"
            />
            <VBtn
              circle
              color="primary"
              @click="removePerson(index)"
            >
              <VIcon
                x-small
                color="white"
                name="trash"
              />
            </VBtn>
          </div>
        </li>
      </template>
    </draggable>
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import Draggable from 'vuedraggable'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import OrganizationPicker from '@/components/organizationPicker.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import { sortArray } from '@/helpers/arrays'
import { People } from '@/routes/endpoints'
import { ref, watch, useTemplateRef } from 'vue'

const props = defineProps({
  roleType: {
    type: String,
    default: undefined
  },
  autofocus: {
    type: Boolean,
    default: true
  },
  modelValue: {
    type: Array,
    default: () => []
  },
  filterByRole: {
    type: Boolean,
    default: false
  },
  createForm: {
    type: Boolean,
    default: true
  },
  hiddenList: {
    type: Boolean,
    default: false
  },
  organization: {
    type: Boolean,
    default: false
  },
  showCreateControls: {
    type: Boolean,
    default: true
  },
  roleTypes: {
    type: Array,
    default: () => []
  }
})

const peopleList = defineModel({
  type: Array,
  default: () => []
})

const emit = defineEmits(['update:modelValue', 'sortable', 'create', 'delete'])

const autocompleteRef = useTemplateRef('autocompleteRef')
const expandPerson = ref(false)
const searchPerson = ref('')
const newNamePerson = ref('')
const person_attributes = ref(makeNewPerson())
const roles_attributes = ref([])

watch(
  peopleList,
  (newVal) => {
    roles_attributes.value = sortArray(processedList(newVal), 'position')
  },
  {
    deep: true,
    immediate: true
  }
)

watch(searchPerson, (newVal) => {
  if (newVal.length) {
    newNamePerson.value = newVal
    fillFields(newVal)
  }
})

watch(
  person_attributes,
  (newVal) => {
    newNamePerson.value = getFullName(newVal.first_name, newVal.last_name)
  },
  {
    deep: true
  }
)

function reset() {
  expandPerson.value = false
  searchPerson.value = ''
  person_attributes.value = makeNewPerson()
  autocompleteRef.value.cleanInput()
}

function getUrl(role) {
  const id = role?.person_id || role?.person?.id

  return id ? `/people/${id}` : '#'
}

function filterRole(role) {
  return props.filterByRole ? role.type === props.roleType : true
}

function makeNewPerson() {
  return {
    first_name: '',
    last_name: '',
    suffix: '',
    prefix: ''
  }
}

function getLabel(item) {
  if (item.organization_id) {
    return item.name
  } else if (item.person) {
    return (
      item.person.cached ||
      getFullName(item.person.first_name, item.person.last_name)
    )
  } else {
    return item.cached || getFullName(item.first_name, item.last_name)
  }
}

function getGlobalId(item) {
  if (item.person) {
    return item.person.global_id
  }

  return item.global_id
}

function switchName() {
  const tmp = person_attributes.value.first_name
  person_attributes.value.first_name = person_attributes.value.last_name
  person_attributes.value.last_name = tmp

  return getFullName(person_attributes.value.first_name, tmp)
}

function fillFields(name) {
  person_attributes.value.first_name = findName(name, 1)
  person_attributes.value.last_name = findName(name, 0)
}

function removePerson(index) {
  const role = roles_attributes.value[index]

  if (role?.id) {
    role._destroy = true
  } else {
    roles_attributes.value.splice(index, 1)
  }

  peopleList.value = roles_attributes.value
  emit('delete', role)
}

function removeFromList(index) {
  roles_attributes.value.splice(index, 1)
  peopleList.value = roles_attributes.value
}

function setInput(text) {
  searchPerson.value = text
}

function findPersonById(personId) {
  return roles_attributes.value.find(
    (item) =>
      (item.person_id === personId || item?.person?.id === personId) &&
      item.type === props.roleType
  )
}

function findName(string, position) {
  let delimiter

  if (string.indexOf(',') > 1) {
    delimiter = ','
  }
  if (string.indexOf(', ') > 1) {
    delimiter = ', '
  }
  if (string.indexOf(' ') > 1 && delimiter !== ', ') {
    delimiter = ' '
  }
  return string.split(delimiter, 2)[position]
}

function processedList(list) {
  return (list || []).map((element) => ({
    id: element.id,
    type: element.type,
    first_name: element.first_name,
    last_name: element.last_name,
    position: element.position,
    person_attributes: element.person_attributes,
    person_id: element.person_id,
    global_id: element.global_id || element?.organization?.global_id,
    person: element.person,
    cached: element.cached,
    _destroy: element._destroy,
    organization_id: element.organization_id || element?.organization?.id,
    name: element.name || element?.organization?.name
  }))
}

function updateIndex() {
  roles_attributes.value.forEach((role, index) => {
    role.position = index + 1
  })
}

function onSortable() {
  updateIndex()
  peopleList.value = roles_attributes.value
  emit('sortable', roles_attributes.value)
}

function getFirstName(person) {
  return person.first_name
}

function getLastName(person) {
  return person.last_name
}

function getFullName(firstName, lastName) {
  return [lastName, firstName].filter(Boolean).join(', ')
}

function createPerson() {
  People.create({ person: person_attributes.value }).then((response) => {
    const person = adapterPerson(response.body)

    roles_attributes.value.push(person)
    autocompleteRef.value.cleanInput()
    expandPerson.value = false
    person_attributes.value = makeNewPerson()
    peopleList.value = roles_attributes.value
    emit('create', person)
  })
}

function adapterPerson(item) {
  return {
    global_id: item.global_id,
    type: props.roleType,
    person_id: item.id,
    cached: item.cached,
    first_name: getFirstName(item),
    last_name: getLastName(item),
    position: roles_attributes.value.length + 1
  }
}

async function _addPersonById({ id }) {
  const role = findPersonById(id)

  if (!role) {
    const { body } = await People.find(id)
    const person = adapterPerson(body)

    roles_attributes.value.push(person)
    reset()
    emit('create', person)
  } else if (role?._destroy) {
    delete role._destroy
  }
  peopleList.value = roles_attributes.value
}

function addPerson(data) {
  const role = findPersonById(data?.id)

  if (!role) {
    const person = adapterPerson(data)

    roles_attributes.value.push(person)
  } else if (role?._destroy) {
    delete role._destroy
  }

  peopleList.value = roles_attributes.value
}

function addOrganization(organization) {
  const alreadyExist = !!roles_attributes.value.find(
    (role) => organization.id === role?.organization_id
  )

  if (!alreadyExist) {
    roles_attributes.value.push({
      global_id: organization.global_id,
      organization_id: organization.id,
      name: organization.name,
      type: props.roleType
    })
    peopleList.value = roles_attributes.value
  }
}
defineExpose({
  addPerson,
  addOrganization
})
</script>
