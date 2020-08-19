<template>
  <div>
    <div class="horizontal-left-content align-start">
      <div class="column-buttons">
        <h2>&nbsp;</h2>
        <button
          type="button"
          class="button normal-input button-default separate-right"
          :disabled="!(Object.keys(selected).length && Object.keys(merge).length)"
          @click="$emit('flip')">Flip</button>
        <button
          class="button normal-input button-submit"
          @click="sendMerge"
          :disabled="!mergeEmpty">Merge people
        </button>
      </div>
      <div class="title-person">
        <h2>Selected person</h2>
        <template v-if="selectedEmpty">
          <p>This person will remain.</p> 
          <h3>{{ selected.cached }} 
          <a target="_blank" :href="`/people/${selected.id}`">Show</a></h3>
        </template>
      </div>
      <div class="title-merge">
        <h2>Person to merge</h2>
        <template v-if="mergeEmpty">
          <p data-icon="warning">This person will be deleted.</p>
          <h3>{{ merge.cached }}
          <a target="_blank" :href="`/people/${merge.id}`">Show</a></h3>
        </template>
      </div>
    </div>
    <table>
      <tbody>
        <tr
          v-for="(property, key, index) in selected"
          v-if="!isNestedProperty(property)"
          class="contextMenuCells"
          :class="{ 
            even: (index % 2 == 0),
            repeated: (isDifferent(property, merge[key]) && merge[key])}">
          <td class="column-property">{{ key | humanize | capitalize }}</td>
          <td class="column-person" v-html="showValue(property)"/>
          <td class="column-merge" v-html="showValue(merge[key])"/>
        </tr>
      </tbody>
    </table>
    <div
      class="margin-medium-top"
      v-if="Object.keys(selected).length || Object.keys(merge).length">
      <ul class="no_bullets context-menu">
        <li class="middle"><div class="circle-info-project in-project margin-small-right"/><span>In project</span></li>
        <li class="middle"><div class="circle-info-project no-in-project margin-small-right"/><span>Not in project</span></li>
        <li class="middle"><div class="circle-info-project nulled margin-small-right"/><span>Not determinated</span></li>
      </ul>
    </div>
    <div class="horizontal-left-content align-start">
      <table-person-roles
        :class="{ 'separate-right': Object.keys(merge).length }"
        v-show="Object.keys(selected).length"
        title="Selected role types"
        :person="selected"/>
      <table-person-roles
        :class="{ 'separate-left': Object.keys(selected).length }"
        v-show="Object.keys(merge).length"
        title="Merge role types"
        :person="merge"/>
    </div>
    <table-roles
      v-if="selected['roles'] && selected['roles'].length"
      title="Selected roles"
      :list="selected['roles']"/>
    <table-roles
      v-if="merge['roles'] && merge['roles'].length"
      title="Merge roles"
      :list="merge['roles']"/>
    <table-annotations
      :person="selected"
      title="Selected annotations"/>
    <table-annotations
      :person="merge"
      title="Merge annotations"/>
  </div>
</template>

<script>

import TableRoles from './tableRoles'
import TableAnnotations from './tableAnnotations'
import TablePersonRoles from './roles_table'

export default {
  components: {
    TablePersonRoles,
    TableAnnotations,
    TableRoles
  },
  name: 'CompareComponent',
  props: {
    selected: {
      type: [Object, Array],
      default: () => { return {} }
    },
    merge: {
      type: [Object, Array],
      default: () => { return {} }
    }
  },
  computed: {
    selectedEmpty() {
      return Object.keys(this.selected).length > 0
    },
    mergeEmpty() {
      return Object.keys(this.merge).length > 0
    }
  },
  filters: {
    capitalize: function (value) {
      if (!value) return ''
      value = value.toString()
      return value.charAt(0).toUpperCase() + value.slice(1)
    },
    humanize: (value) => {
      return (typeof value == 'string' ? value.replace(/[_]/gm, " ") : value)
    }
  },
  methods: {
    isDifferent(value, compare) {
      return (value != compare)
    },
    isNestedProperty(value) {
      return (Array.isArray(value) || typeof value == 'object' && value != null)
    },
    sendMerge() {
      if(confirm("Are you sure you want to merge?")) {
        this.$emit('merge')
      }
    },
    showValue(value) {
      return this.$options.filters.capitalize(this.$options.filters.humanize(value))
    }
  }
}
</script>

<style lang="scss" scoped>
  .repeated {
    color: red
  }
  .no-difference {
    display: none
  }
  .column-property {
    min-width: 105px;
  }
  .column-buttons {
    min-width: 136px;
  }
  .column-person, .column-merge {
    min-width: 250px;
  }
  .title-merge, .title-person {
    min-width: 250px;
    padding-left: 1em;
    padding-right: 1em;
  }
  .circle-info-project {
    border-radius: 50%;
    width: 24px;
    height: 24px;
  }
  .nulled {
    background-color: #E5D2BE;
  }
  .in-project {
    background-color: #5D9ECE;
  }
  .no-in-project {
    background-color: #C38A8A;
  }
</style>
