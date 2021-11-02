<template>
  <div>
    <div
      v-if="createForm"
      class="horizontal-left-content align-start">
      <div class="horizontal-left-content">
        <autocomplete
          :autofocus="autofocus"
          class="separate-right"
          url="/people/autocomplete"
          label="label_html"
          display="label"
          min="2"
          @getInput="setInput"
          ref="autocomplete"
          @getItem="addCreatedPerson"
          :clear-after="true"
          placeholder="Family name, given name"
          param="term"/>
        <default-pin
          class="button-circle"
          type="People"
          @getItem="addCreatedPerson({ object_id: $event.id, label: $event.label })"
          section="People"/>
      </div>
      <div
        class="flex-wrap-column separate-left"
        v-if="searchPerson.length > 0">
        <div>
          <input
            class="normal-input"
            disabled
            :value="newNamePerson">
          <button
            type="button"
            class="normal-input button button-submit"
            @click="createPerson()">Add new
          </button>
          <button
            type="button"
            class=" normal-input button button-default"
            @click="switchName(newNamePerson)">Switch
          </button>
          <button
            type="button"
            class="normal-input button button-default"
            @click="expandPerson = !expandPerson">Expand
          </button>
        </div>
        <hr>
        <div
          class="flex-wrap-column"
          v-if="expandPerson">
          <div class="field label-above">
            <label>Given name</label>
            <input
              v-model="person_attributes.first_name"
              type="text">
          </div>
          <div class="field label-above">
            <label>Family name prefix</label>
            <input
              v-model="person_attributes.prefix"
              type="text">
          </div>
          <div class="field label-above">
            <label>Family name</label>
            <input
              v-model="person_attributes.last_name"
              type="text">
          </div>
          <div class="field label-above">
            <label>Family name suffix</label>
            <input
              v-model="person_attributes.suffix"
              type="text">
          </div>
        </div>
      </div>
    </div>
    <draggable
      v-if="!hiddenList"
      class="table-entrys-list"
      element="ul"
      v-model="roles_attributes"
      item-key="id"
      @end="onSortable">
      <template #item="{ element, index }">
        <li
          class="list-complete-item flex-separate middle"
          v-if="!element.hasOwnProperty('_destroy') && filterRole(element)">
          <a
            v-if="(element.hasOwnProperty('person_id') || element.hasOwnProperty('person'))"
            :href="getUrl(element)"
            target="_blank"
            v-html="getLabel(element)"/>
          <span
            v-else
            v-html="getLabel(element)"/>

          <span
            class="circle-button btn-delete"
            @click="removePerson(index)"/>
        </li>
      </template>
    </draggable>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import Draggable from 'vuedraggable'
import DefaultPin from './getDefaultPin'
import { People } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    Draggable,
    DefaultPin
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
    }
  },

  emits: [
    'update:modelValue',
    'sortable',
    'create',
    'delete'
  ],

  data () {
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
      handler (newVal) {
        this.roles_attributes = this.sortPosition(this.processedList(newVal))
      },
      deep: true,
      immediate: true
    },
    searchPerson (newVal) {
      if (newVal.length > 0) {
        this.newNamePerson = newVal
        this.fillFields(newVal)
      }
    },
    person_attributes: {
      handler (newVal) {
        this.newNamePerson = this.getFullName(newVal.first_name, newVal.last_name)
      },
      deep: true
    }
  },
  methods: {
    reset () {
      this.expandPerson = false
      this.searchPerson = ''
      this.person_attributes = this.makeNewPerson()
      this.$refs.autocomplete.cleanInput()
    },

    getUrl(role) {
      return (role.hasOwnProperty('person_id') || role.hasOwnProperty('person'))
        ? `/people/${role?.person_id || role.person.id}`
        : '#'
    },

    filterRole (role) {
      return this.filterByRole
        ? role.type === this.roleType
        : true
    },

    makeNewPerson () {
      return {
        first_name: '',
        last_name: '',
        suffix: '',
        prefix: ''
      }
    },

    getLabel (person) {
      if (person.hasOwnProperty('person_attributes')) {
        return this.getFullName(person.person_attributes.first_name, person.person_attributes.last_name)
      } else if (person.hasOwnProperty('person')) {
        return this.getFullName(person.person.first_name, person.person.last_name)
      } else {
        return this.getFullName(person.first_name, person.last_name)
      }
    },

    switchName (name) {
      const tmp = this.person_attributes.first_name
      this.person_attributes.first_name = this.person_attributes.last_name
      this.person_attributes.last_name = tmp
      return this.getFullName(this.person_attributes.first_name, tmp)
    },

    fillFields (name) {
      this.person_attributes.first_name = this.getFirstName(name)
      this.person_attributes.last_name = this.getLastName(name)
    },

    removePerson (index) {
      if (this.roles_attributes[index].hasOwnProperty('id') && this.roles_attributes[index].id) {
        this.roles_attributes[index] = {id: this.roles_attributes[index].id, _destroy: true }
        this.$emit('update:modelValue', this.roles_attributes)
        this.$emit('delete', this.roles_attributes[index])
      }
      else {
        const person = this.roles_attributes[index]
        this.roles_attributes.splice(index, 1)
        this.$emit('update:modelValue', this.roles_attributes)
        this.$emit('delete', person)
      }
    },

    setInput (text) {
      this.searchPerson = text
    },

    sortPosition (list) {
      list.sort((a, b) =>
        a.position > b.position ? 1 : -1
      )
      return list
    },

    alreadyExist (personId) {
      return !!this.roles_attributes.find(item => personId === item?.person_id)
    },

    processedList (list) {
      if (!list) return []

      return list.map((element, index) => {
        const item = {
          id: element?.id,
          type: element.type,
          first_name: element?.first_name,
          last_name: element?.last_name,
          position: element.position
        }

        if (element.hasOwnProperty('person_attributes')) {
          item.person_attributes = element.person_attributes
        }

        if (element.hasOwnProperty('person_id')) {
          item.person_id = element.person_id
        }

        if (element.hasOwnProperty('person')) {
          item.person = element.person
        }
        if (element.hasOwnProperty('_destroy')) {
          item._destroy = element._destroy
        }
        return item
      })
    },

    updateIndex () {
      this.roles_attributes.forEach((element, index) => {
        this.roles_attributes[index].position = (index + 1)
      })
    },

    onSortable () {
      this.updateIndex()
      this.$emit('update:modelValue', this.roles_attributes)
      this.$emit('sortable', this.roles_attributes)
    },

    findName (string, position) {
      let delimiter

      if (string.indexOf(',') > 1) {
        delimiter = ','
      }
      if (string.indexOf(', ') > 1) {
        delimiter = ', '
      }
      if (string.indexOf(' ') > 1 && delimiter != ', ') {
        delimiter = ' '
      }
      return string.split(delimiter, 2)[position]
    },

    getFirstName (string) {
      if ((string.indexOf(',') > 1) || (string.indexOf(' ') > 1)) {
        return this.findName(string, 1)
      } else {
        return ''
      }
    },

    getLastName (string) {
      if ((string.indexOf(',') > 1) || (string.indexOf(' ') > 1)) {
        return this.findName(string, 0)
      } else {
        return string
      }
    },

    getFullName (first_name, last_name) {
      let separator = ''
      if (!!last_name && !!first_name) {
        separator = ', '
      }
      return (last_name + separator + (first_name != null ? first_name : ''))
    },

    createPerson () {
      People.create({ person: this.person_attributes }).then(response => {
        const person = response.body

        person.label = person.object_tag
        person.object_id = person.id
        this.roles_attributes.push(this.addPerson(person))
        this.$emit('update:modelValue', this.roles_attributes)
        this.$refs.autocomplete.cleanInput()
        this.expandPerson = false
        this.person_attributes = this.makeNewPerson()
        this.$emit('create', person)
      })
    },

    addPerson (item) {
      return {
        type: this.roleType,
        person_id: item.object_id,
        first_name: this.getFirstName(item.label),
        last_name: this.getLastName(item.label),
        position: (this.roles_attributes.length + 1)
      }
    },

    addCreatedPerson (item) {
      if (!this.alreadyExist(item.object_id)) {
        this.roles_attributes.push(this.addPerson(item))
        this.$emit('update:modelValue', this.roles_attributes)
        this.$emit('create', this.addPerson(item))
        this.person_attributes = this.makeNewPerson()
        this.searchPerson = ''
      }
    },

    setPerson (person) {
      person.position = (this.roles_attributes.length + 1)
      this.roles_attributes.push(person)
      this.$emit('update:modelValue', this.roles_attributes)
    }
  }
}
</script>
<style lang="scss">
  .table-entrys-list {
    padding: 0px;
    position: relative;

    li {
      margin: 0px;
      padding: 1em 0;
      display: flex;
      justify-content: space-between;
      border-bottom: 1px solid #f5f5f5;
    }


  }
</style>
