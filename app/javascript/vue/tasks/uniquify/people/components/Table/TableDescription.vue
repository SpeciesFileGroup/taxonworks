<template>
  <div
    class="full_width"
    v-if="Object.keys(personRoles).length"
  >
    <h3>{{ title }}</h3>
    <table class="table-roles">
      <thead>
        <tr>
          <th>Type</th>
          <th>In project</th>
          <th>Not in project</th>
          <th>Not determinated</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(roleList, roleType, index) in personRoles"
          :key="roleType"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }"
        >
          <td v-text="roleType" />
          <td
            v-for="(value, key) in rolesCount(roleList)"
            :key="key"
            class="column-property"
          >
            {{ value ? value : '' }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  person: {
    type: Object,
    default: () => ({})
  },

  title: {
    type: String,
    required: true
  }
})

const personRoles = computed(() => {
  const roles = props.person?.roles || []
  const roleList = roles.reduce(
    (prev, curr, index) => {
      const type = curr.role_object_type

      return {
        ...prev,
        [type]: [...prev[type] || [], curr]
      }
    }, {})

  return Object.fromEntries(Object.entries(roleList).sort())
})

const classForRoleProject = role => {
  if (role.in_project) {
    return 'in-project'
  } else if (role.project_id === null) {
    return 'nulled'
  } else {
    return 'no-in-project'
  }
}

const rolesCount = roleList =>
  roleList.reduce((acc, curr, index) => {
    if (curr.in_project) {
      acc.inProject++
    } else if (curr.project_id === null) {
      acc.nulled++
    } else {
      acc.noInProject++
    }

    return acc
  }, {
    inProject: 0,
    noInProject: 0,
    nulled: 0
  })

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
