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
          <td v-html="item.object_tag" />
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { watch, ref } from 'vue'
import { People } from 'routes/endpoints'

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

const personRoles = ref([])

watch(() => props.person,
  async person => {
    personRoles.value = person?.id
      ? (await People.roles(person.id)).body
      : []
  },
  { deep: true }
)

const classForRoleProject = role => {
  if (role.in_project) {
    return 'in-project'
  } else if (role.project_id === null) {
    return 'nulled'
  } else {
    return 'no-in-project'
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
