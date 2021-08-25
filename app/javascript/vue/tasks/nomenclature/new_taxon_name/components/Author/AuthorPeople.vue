<template>
  <div class="flex-separate">
    <role-picker
      v-model="roles"
      @create="updateLastChange"
      @delete="updateLastChange"
      @sortable="updateLastChange"
      @update="updatePeople"
      role-type="TaxonNameAuthor"
    />
    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!citation || isAlreadyClone"
        @click="cloneFromSource"
      >
        Clone from source
      </button>
    </div>
  </div>
</template>
<script>

import { ROLE_TAXON_NAME_AUTHOR } from 'constants/index.js'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import RolePicker from 'components/role_picker.vue'

export default {
  components: { RolePicker },

  computed: {
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },

    taxon: {
      get () {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxon, value)
      }
    },

    roles: {
      get () {
        const roles = this.$store.getters[GetterNames.GetRoles]

        return roles
          ? roles.sort((a, b) => a.position - b.position)
          : []
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    },

    isAlreadyClone () {
      if (this.citation.source.author_roles.length === 0) return true

      const authorsId = this.citation.source.author_roles.map(author => Number(author.person.id))
      const personsIds = this.roles.map(role => role.person.id)

      return authorsId.every(id => personsIds.includes(id))
    }
  },

  methods: {
    cloneFromSource () {
      const personsIds = this.roles.map(role => role.person.id)

      const authorsPerson = this.citation.source.author_roles.map(author => {
        if (!personsIds.includes(Number(author.person.id))) {
          return {
            person_id: author.person.id,
            type: ROLE_TAXON_NAME_AUTHOR
          }
        }
      })
      this.roles = authorsPerson
      this.updateTaxonName()
    },

    updateTaxonName () {
      if (this.isAutosaveActive) {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      }
    },

    updateLastChange () {
      this.$store.commit(MutationNames.UpdateLastChange)
    },

    updatePeople (list) {
      this.$store.commit(MutationNames.SetRoles, list)
    }
  }
}
</script>
