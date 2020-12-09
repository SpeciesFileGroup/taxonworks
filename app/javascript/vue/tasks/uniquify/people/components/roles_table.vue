<template>
  <div
    class="full_width"
    v-if="personRoles.length">
    <h3>{{ title }}</h3>
    <table class="table-roles">
      <tbody>
        <tr
          v-for="(item, index) in personRoles"
          :key="item.id"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }">
          <td
            class="column-property"
            :class="classForRoleProject(item)">
            {{ item.role_object_type }}
          </td>
          <td v-html="item.role_object_tag" />
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'

export default {
  props: {
    person: {
      type: Object,
      default: () => { return {} }
    },
    title: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      personRoles: []
    }
  },
  watch: {
    person: {
      handler (newVal) {
        if (newVal.hasOwnProperty('id')) {
          this.getPerson(newVal.id)
        } else {
          this.personRoles = []
        }
      },
      deep: true
    }
  },
  methods: {
    getPerson () {
      AjaxCall('get', `/people/${this.person.id}/roles.json`).then(response => {
        this.personRoles = response.body
      })
    },
    classForRoleProject (role) {
      return role.in_project ? 'in-project' : role.project_id === null ? 'nulled' : 'no-in-project'
    }
  }
}
</script>

<style lang="scss" scoped>
  .table-roles {
    display: table;
    table-layout: fixed;
    td {
      word-break: break-all;
    }
    .column-property {
      min-width: 100px;
    }
    .nulled {
      border-left: 4px solid;
      border-left-color: #E5D2BE;
    }
    .in-project {
      border-left: 4px solid;
      border-left-color: #5D9ECE;
    }
    .no-in-project {
      border-left: 4px solid;
      border-left-color: #C38A8A;
    }
  }
</style>
