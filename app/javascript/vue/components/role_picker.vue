<template>
  <div>
    <template v-if="createForm">
      <div v-if="organization">
        <organization-picker @get-item="addOrganization" />
      </div>

      <div
        v-else
        class="horizontal-left-content align-start"
      >
        <div class="horizontal-left-content">
          <autocomplete
            ref="autocomplete"
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
          v-if="searchPerson.length > 0"
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
          <hr />
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

          <v-btn
            circle
            color="primary"
            @click="removePerson(index)"
          >
            <v-icon
              x-small
              color="white"
              name="trash"
            />
          </v-btn>
        </li>
      </template>
    </draggable>
  </div>
</template>

<script>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import Draggable from 'vuedraggable'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import OrganizationPicker from '@/components/organizationPicker.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { sortArray } from '@/helpers/arrays'
import { People } from '@/routes/endpoints'

export default {
  components: {
    Autocomplete,
    Draggable,
    DefaultPin,
    OrganizationPicker,
    VBtn,
    VIcon
  },

  props: {
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
    roleTypes: {
      type: Array,
      default: () => []
    }
  },

  emits: ['update:modelValue', 'sortable', 'create', 'delete'],

  data() {
    return {
      expandPerson: false,
      searchPerson: '',
      newNamePerson: '',
      person_attributes: this.makeNewPerson(),
      roles_attributes: []
    }
  },

  watch: {
    modelValue: {
      handler(newVal) {
        this.roles_attributes = sortArray(
          this.processedList(newVal),
          'position'
        )
      },
      deep: true,
      immediate: true
    },
    searchPerson(newVal) {
      if (newVal.length > 0) {
        this.newNamePerson = newVal
        this.fillFields(newVal)
      }
    },
    person_attributes: {
      handler(newVal) {
        this.newNamePerson = this.getFullName(
          newVal.first_name,
          newVal.last_name
        )
      },
      deep: true
    }
  },
  methods: {
    reset() {
      this.expandPerson = false
      this.searchPerson = ''
      this.person_attributes = this.makeNewPerson()
      this.$refs.autocomplete.cleanInput()
    },

    getUrl(role) {
      const id = role?.person_id || role?.person?.id

      return id ? `/people/${id}` : '#'
    },

    filterRole(role) {
      return this.filterByRole ? role.type === this.roleType : true
    },

    makeNewPerson() {
      return {
        first_name: '',
        last_name: '',
        suffix: '',
        prefix: ''
      }
    },

    getLabel(item) {
      if (item.organization_id) {
        return item.name
      } else if (item.person) {
        return (
          item.person.cached ||
          this.getFullName(item.person.first_name, item.person.last_name)
        )
      } else {
        return item.cached || this.getFullName(item.first_name, item.last_name)
      }
    },

    switchName() {
      const tmp = this.person_attributes.first_name
      this.person_attributes.first_name = this.person_attributes.last_name
      this.person_attributes.last_name = tmp

      return this.getFullName(this.person_attributes.first_name, tmp)
    },

    fillFields(name) {
      this.person_attributes.first_name = this.findName(name, 1)
      this.person_attributes.last_name = this.findName(name, 0)
    },

    removePerson(index) {
      const role = this.roles_attributes[index]

      if (role?.id) {
        role._destroy = true
      } else {
        this.roles_attributes.splice(index, 1)
      }

      this.$emit('update:modelValue', this.roles_attributes)
      this.$emit('delete', role)
    },

    setInput(text) {
      this.searchPerson = text
    },

    findPersonById(personId) {
      return this.roles_attributes.find(
        (item) =>
          (item.person_id === personId || item?.person?.id === personId) &&
          item.type === this.roleType
      )
    },

    findName(string, position) {
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
    },

    processedList(list) {
      return (list || []).map((element) => ({
        id: element.id,
        type: element.type,
        first_name: element.first_name,
        last_name: element.last_name,
        position: element.position,
        person_attributes: element.person_attributes,
        person_id: element.person_id,
        person: element.person,
        cached: element.cached,
        _destroy: element._destroy,
        organization_id: element.organization_id || element?.organization?.id,
        name: element.name || element?.organization?.name
      }))
    },

    updateIndex() {
      this.roles_attributes.forEach((role, index) => {
        role.position = index + 1
      })
    },

    onSortable() {
      this.updateIndex()
      this.$emit('update:modelValue', this.roles_attributes)
      this.$emit('sortable', this.roles_attributes)
    },

    getFirstName(person) {
      return person.first_name
    },

    getLastName(person) {
      return person.last_name
    },

    getFullName(firstName, lastName) {
      return [lastName, firstName].filter(Boolean).join(', ')
    },

    createPerson() {
      People.create({ person: this.person_attributes }).then((response) => {
        const person = this.adapterPerson(response.body)

        this.roles_attributes.push(person)
        this.$refs.autocomplete.cleanInput()
        this.expandPerson = false
        this.person_attributes = this.makeNewPerson()
        this.$emit('update:modelValue', this.roles_attributes)
        this.$emit('create', person)
      })
    },

    adapterPerson(item) {
      return {
        type: this.roleType,
        person_id: item.id,
        cached: item.cached,
        first_name: this.getFirstName(item),
        last_name: this.getLastName(item),
        position: this.roles_attributes.length + 1
      }
    },

    async _addPersonById({ id }) {
      const role = this.findPersonById(id)

      if (!role) {
        const { body } = await People.find(id)
        const person = this.adapterPerson(body)

        this.roles_attributes.push(person)
        this.reset()
        this.$emit('create', person)
        this.$emit('update:modelValue', this.roles_attributes)
      } else if (role?._destroy) {
        delete role._destroy
        this.$emit('update:modelValue', this.roles_attributes)
      }
    },

    addPerson(data) {
      const role = this.findPersonById(data?.id)

      if (!role) {
        const person = this.adapterPerson(data)

        this.roles_attributes.push(person)
        this.$emit('update:modelValue', this.roles_attributes)
      } else if (role?._destroy) {
        delete role._destroy
        this.$emit('update:modelValue', this.roles_attributes)
      }
    },

    addOrganization(organization) {
      const alreadyExist = !!this.roles_attributes.find(
        (role) => organization.id === role?.organization_id
      )

      if (!alreadyExist) {
        this.roles_attributes.push({
          organization_id: organization.id,
          name: organization.name,
          type: this.roleType
        })
        this.$emit('update:modelValue', this.roles_attributes)
      }
    }
  }
}
</script>
