<template>
  <block-layout :warning="!list.length">
    <template #header>
      <h3>Determinations</h3>
    </template>
    <template #body>
      <div id="taxon-determination-digitize">
        <taxon-determination-form
          ref="taxonDeterminationComponent"
          v-model:lock-determiner="locked.taxon_determination.roles_attributes"
          v-model:lock-otu="locked.taxon_determination.otu_id"
          v-model:lock-date="locked.taxon_determination.dates"
          @on-add="addDetermination"
        />
        <taxon-determination-list
          v-model="list"
          v-model:lock="locked.taxonDeterminations"
          @edit="editTaxonDetermination"
          @delete="removeTaxonDetermination"
        />
      </div>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from 'components/TaxonDetermination/TaxonDeterminationList.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'

export default {
  components: {
    BlockLayout,
    TaxonDeterminationForm,
    TaxonDeterminationList
  },

  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },

    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },

    list: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDeterminations, value)
      }
    }
  },

  methods: {
    addDetermination (determination) {
      this.$store.commit(MutationNames.AddTaxonDetermination, determination)
    },

    removeTaxonDetermination (determination) {
      this.$store.dispatch(ActionNames.RemoveTaxonDetermination, determination)
    },

    editTaxonDetermination (item) {
      this.$refs.taxonDeterminationComponent.setDetermination({
        id: item.id,
        uuid: item.uuid,
        global_id: item.global_id,
        otu_id: item.otu_id,
        day_made: item.day_made,
        month_made: item.month_made,
        year_made: item.year_made,
        position: item.position,
        roles_attributes: item?.determiner_roles || item.roles_attributes || []
      })
    }
  }
}
</script>

<style lang="scss">
  #taxon-determination-digitize {
    label {
      display: block;
    }
    li label {
      display: inline;
    }
    .role-picker {
      .vue-autocomplete-input {
        max-width: 150px;
      }
    }
  }

</style>
