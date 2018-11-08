<template>
  <div>
    <div class="horizontal-left-content align-start">
      <autocomplete
        :autofocus="autofocus"
        class="separate-right"
        url="/people/autocomplete"
        label="label"
        min="2"
        @getInput="setInput"
        event-send="role_picker"
        :clear-after="true"
        placeholder="Family name, given name"
        param="term"/>
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
            class=" normal-input button"
            @click="switchName(newNamePerson)">Switch
          </button>
          <button
            type="button"
            class="normal-input button"
            @click="expandPerson = !expandPerson">Expand
          </button>
        </div>
        <hr>
        <div
          class="flex-wrap-column"
          v-if="expandPerson">
          <div class="field">
            <label>Given name</label><br>
            <input
              v-model="person_attributes.first_name"
              type="text">
          </div>
          <div class="field">
            <label>Family name prefix</label><br>
            <input
              v-model="person_attributes.prefix"
              type="text">
          </div>
          <div class="field">
            <label>Family name</label><br>
            <input
              v-model="person_attributes.last_name"
              type="text">
          </div>
          <div class="field">
            <label>Family name suffix</label><br>
            <input
              v-model="person_attributes.suffix"
              type="text">
          </div>
        </div>
      </div>
    </div>
    <ul class="table-entrys-list">
      <draggable
        v-model="roles_attributes"
        @end="onSortable">
        <li
          class="flex-separate middle"
          v-for="(role, index) in roles_attributes"
          v-if="!role.hasOwnProperty('_destroy')">
          <a
            :href="getUrl(role)"
            target="_blank"
            v-html="getLabel(role)"/>
          <span
            class="circle-button btn-delete"
            @click="removePerson(index)"/>
        </li>
      </draggable>
    </ul>
  </div>
</template>

<script>

  const autocomplete = require('./autocomplete.vue').default
  const draggable = require('vuedraggable')

  export default {
    components: {
      autocomplete,
      draggable
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
      value: undefined
    },
    data: function () {
      return {
        expandPerson: false,
        searchPerson: '',
        newNamePerson: '',
        person_attributes: this.makeNewPerson(),
        roles_attributes: this.sortPosition(this.processedList(this.value))
      }
    },
    mounted: function () {
      this.$on('role_picker', function (item) {
        if (!this.alreadyExist(item.object_id)) {
          this.roles_attributes.push(this.addPerson(item))
          this.$emit('input', this.roles_attributes)
          this.$emit('create', this.addPerson(item))
          this.person_attributes = this.makeNewPerson()
        }
      })
    },
    watch: {
      value: function (newVal) {
        this.roles_attributes = this.sortPosition(this.processedList(this.value))
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
      getUrl(role) {
        if (role.hasOwnProperty('person')) {
          return `/people/${role.person.id}/edit`
        } else {
          return '#'
        }
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
        this.$set(this.roles_attributes[index], '_destroy', true)
        this.$emit('input', this.roles_attributes)
        this.$emit('delete', this.roles_attributes[index])
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
          return (personId == item.person.id)
        }) != undefined)
      },
      processedList: function (list) {
        if (list == undefined) return []
        let tmp = []

        list.forEach(function (element, index) {
          let item = {
            id: element.id,
            person: {
              id: element.person.id
            },
            first_name: element.person.first_name,
            last_name: element.person.last_name,
            position: element.position
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
        let person = {
          type: this.roleType,
          person_attributes: this.person_attributes,
          position: (this.roles_attributes.length + 1)
        }
        this.roles_attributes.push(person)
        this.$emit('input', this.roles_attributes)
        this.expandPerson = false
        this.person_attributes = this.makeNewPerson()
        this.$emit('create', person)
      },
      addPerson: function (item) {
        return {
          type: this.roleType,
          person_id: item.object_id,
          person: {
            id: item.object_id
          },
          first_name: this.getFirstName(item.label),
          last_name: this.getLastName(item.label),
          position: (this.roles_attributes.length + 1)
        }
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
      border-top: 1px solid #f5f5f5;
    }
  }
</style>
