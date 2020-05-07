<template>
  <div v-if="personRoles.length">
    <h3>{{ title }}</h3>
    <table class="table-roles">
      <tbody>
        <tr
          v-for="(item, index) in personRoles"
          :key="item.id"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }">
          <td class="column-property">
            {{ item.role_object_type }}
          </td>
          <td v-html="item.role_object_tag"/>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
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
  data() {
    return {
      personRoles: []
    }
  },
  watch: {
    person: {
      handler(newVal) {
        if(newVal.hasOwnProperty('id')) {
          this.getPerson(newVal.id)
        }
        else {
          this.personRoles = []
        }
      },
      deep: true
    }
  },
  methods: {
    getPerson() {
      this.$http.get(`/people/${this.person.id}/roles.json`).then(response => {
        this.personRoles = response.body
      })
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
  }
</style>
