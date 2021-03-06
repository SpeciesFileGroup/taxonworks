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
      @end="onSortable">
      <li
        class="list-complete-item flex-separate middle"
        v-for="(role, index) in roles_attributes"
        v-if="!role.hasOwnProperty('_destroy') && filterRole(role)">
        <template>
          <a
            v-if="(role.hasOwnProperty('person_id') || role.hasOwnProperty('person'))"
            :href="getUrl(role)"
            target="_blank"
            v-html="getLabel(role)"/>
          <span
            v-else
            v-html="getLabel(role)"/>
        </template>
        <span
          class="circle-button btn-delete"
          @click="removePerson(index)"/>
      </li>
    </draggable>
  </div>
</template>

<script>

  import Autocomplete from './autocomplete.vue'
  import Draggable from 'vuedraggable'
  import DefaultPin from './getDefaultPin'
  import AjaxCall from 'helpers/ajaxCall'

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
      value: { 
        type: Array,
        default: () => { return [] }
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
    data: function () {
      return {
        expandPerson: false,
        searchPerson: '',
        newNamePerson: '',
        person_attributes: this.makeNewPerson(),
        roles_attributes: []
      }
    },
    watch: {
      value: {
        handler(newVal) {
          this.roles_attributes = this.sortPosition(this.processedList(newVal))
        },
        deep: true,
        immediate: true
      },
      searchPerson: function (newVal) {
        if (newVal.length > 0) {
          this.newNamePerson = newVal
          this.fillFields(newVal)
        }
      },
      person_attributes: {
        handler: function (newVal) {
          this.newNamePerson = this.getFullName(newVal.first_name, newVal.last_name)
        },
        deep: true
      }
    },
    methods: {
      reset() {
        this.expandPerson = false,
        this.searchPerson = '',
        this.person_attributes = this.makeNewPerson(),
        this.$refs.autocomplete.cleanInput()
      },
      getUrl(role) {
        if (role.hasOwnProperty('person_id') || role.hasOwnProperty('person')) {
          return `/people/${role.hasOwnProperty('person_id') ? role.person_id : role.person.id}`
        } else {
          return '#'
        }
      },
      filterRole(role) {
        if(this.filterByRole) {
          return (role.type == this.roleType)
        }
        return true
      },
      makeNewPerson: function () {
        return {
          first_name: '',
          last_name: '',
          suffix: '',
          prefix: ''
        }
      },
      getLabel: function (person) {
        if (person.hasOwnProperty('person_attributes')) {
          return this.getFullName(person.person_attributes.first_name, person.person_attributes.last_name)
        } else if (person.hasOwnProperty('person')) {
          return this.getFullName(person.person.first_name, person.person.last_name)
        } else {
          return this.getFullName(person.first_name, person.last_name)
        }
      },
      switchName: function (name) {
        let tmp = this.person_attributes.first_name
        this.person_attributes.first_name = this.person_attributes.last_name
        this.person_attributes.last_name = tmp
        return this.getFullName(this.person_attributes.first_name, tmp)
      },
      fillFields: function (name) {
        this.person_attributes.first_name = this.getFirstName(name)
        this.person_attributes.last_name = this.getLastName(name)
      },
      removePerson: function (index) {
        if(this.roles_attributes[index].hasOwnProperty('id') && this.roles_attributes[index].id) {
          this.$set(this.roles_attributes, index, {id: this.roles_attributes[index].id, _destroy: true })
          this.$emit('input', this.roles_attributes)
          this.$emit('delete', this.roles_attributes[index])
        }
        else {
          let person = this.roles_attributes[index]
          this.roles_attributes.splice(index, 1)
          this.$emit('input', this.roles_attributes)
          this.$emit('delete', person)          
        }
      },
      setInput: function (text) {
        this.searchPerson = text
      },
      sortPosition: function (list) {
        list.sort(function (a, b) {
          if (a.position > b.position) {
            return 1
          }
          return -1
        })
        return list
      },
      alreadyExist: function (personId) {
        return (this.roles_attributes.find(function (item) {
          return (personId == item['person_id'])
        }) != undefined)
      },
      processedList: function (list) {
        if (list == undefined) return []
        let tmp = []

        list.forEach(function (element, index) {
          let item = {
            id: (element.hasOwnProperty('id') ? element.id : undefined),
            type: element.type,
            first_name: (element['first_name'] ? element.first_name : undefined),
            last_name: (element['last_name'] ? element.last_name : undefined),
            position: element.position
          }
          if(element.hasOwnProperty('person_attributes')) {
            item.person_attributes = element.person_attributes            
          }
          if(element.hasOwnProperty('person_id')) {
            item.person_id = element.person_id
          }
          if(element.hasOwnProperty('person')) {
            item.person = element.person
          }
          if(element.hasOwnProperty('_destroy')) {
            item['_destroy'] = element._destroy
          }
          tmp.push(item)
        })
        return tmp
      },
      updateIndex: function () {
        var that = this
        this.roles_attributes.forEach(function (element, index) {
          that.roles_attributes[index].position = (index + 1)
        })
      },
      onSortable: function () {
        this.updateIndex()
        this.$emit('input', this.roles_attributes)
        this.$emit('sortable', this.roles_attributes)
      },
      findName: function (string, position) {
        var delimiter
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
      getFirstName: function (string) {
        if ((string.indexOf(',') > 1) || (string.indexOf(' ') > 1)) {
          return this.findName(string, 1)
        } else {
          return ''
        }
      },
      getLastName: function (string) {
        if ((string.indexOf(',') > 1) || (string.indexOf(' ') > 1)) {
          return this.findName(string, 0)
        } else {
          return string
        }
      },
      getFullName: function (first_name, last_name) {
        var separator = ''
        if (!!last_name && !!first_name) {
          separator = ', '
        }
        return (last_name + separator + (first_name != null ? first_name : ''))
      },
      createPerson: function () {
        AjaxCall('post', `/people.json`, { person: this.person_attributes }).then(response => {
          let person = response.body
          person.label = person.object_tag
          person.object_id = person.id
          this.roles_attributes.push(this.addPerson(person))
          this.$emit('input', this.roles_attributes)
          this.$refs.autocomplete.cleanInput()
          this.expandPerson = false
          this.person_attributes = this.makeNewPerson()
          this.$emit('create', person)
        })
      },
      addPerson: function (item) {
        return {
          type: this.roleType,
          person_id: item.object_id,
          first_name: this.getFirstName(item.label),
          last_name: this.getLastName(item.label),
          position: (this.roles_attributes.length + 1)
        }
      },
      addCreatedPerson: function (item) {
        if (!this.alreadyExist(item.object_id)) {
          this.roles_attributes.push(this.addPerson(item))
          this.$emit('input', this.roles_attributes)
          this.$emit('create', this.addPerson(item))
          this.person_attributes = this.makeNewPerson()
          this.searchPerson = ''
        }
      },
      setPerson: function (person) {
        person.position = (this.roles_attributes.length + 1)
        this.roles_attributes.push(person)
        this.$emit('input', this.roles_attributes)
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
      padding: 6px;
      display: flex;
      justify-content: space-between;
      border-top: 1px solid #f5f5f5;
    }
  }
</style>
