<template>
  <div>
    <div class="horizontal-left-content">
      <div class="title">
        <button
          type="button"
          class="button normal-input button-default"
          :disabled="!(Object.keys(selected).length && Object.keys(merge).length)"
          @click="$emit('flip')">Flip</button>
      </div>
      <h2 class="title-person">Selected Person</h2>
      <h2 class="title-merge">Merge Person</h2>
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
          <td class="column-person">{{ property | humanize | capitalize }}</td>
          <td class="column-merge">{{ merge[key] | humanize | capitalize }}</td>
        </tr>
      </tbody>
    </table>
    <table-roles
      v-if="selected['roles']"
      title="Selected roles"
      :list="selected['roles']"/>
    <table-roles
      v-if="merge['roles']"
      title="Merge roles"
      :list="merge['roles']"/>
    <table-annotations
      :person="selected"
      title="Selected annotations"/>
    <table-annotations
      :person="merge"
      title="Merge annotations"
    />
  </div>
</template>

<script>

import CompareComponent from './compare'
import TableRoles from './tableRoles'
import TableAnnotations from './tableAnnotations'

export default {
  components: {
    CompareComponent,
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
    min-width: 100px;
  }
  .column-person, .column-merge {
    min-width: 250px;
  }
  .title-merge, .title-person {
    min-width: 250px;
    padding-left: 0.5em;
    padding-right: 0.5em;
  }
  .title {
    min-width: 100px;
    padding: 1em;
  }
</style>
