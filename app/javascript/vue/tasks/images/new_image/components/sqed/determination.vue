<template>
  <div>
    <h3>Taxon determination</h3>
    <taxon-determination-form @onAdd="addDetermination"/>
    <div class="flex-separate margin-medium-top">
      <span>Determinations</span>
      <lock-component v-model="settings.lock.taxon_determinations"/>
    </div>
    <display-list
      :list="list"
      @delete="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import DisplayList from 'components/displayList.vue'
import LockComponent from 'components/ui/VLock/index.vue'

export default {
  components: {
    TaxonDeterminationForm,
    DisplayList,
    LockComponent
  },

  computed: {
    list: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDetermination, value)
      }
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  methods: {
    addDetermination (taxonDetermination) {
      if (this.list.find(determination => determination.otu_id === taxonDetermination.otu_id)) return
      this.list.push(taxonDetermination)
    },

    removeTaxonDetermination (determination) {
      this.list.splice(this.list.findIndex(item => item.otu_id === determination.id), 1)
    }
  }
}
</script>

<style lang="scss" scoped>
    label {
      display: block;
    }
    .date-fields {
      input {
        max-width: 60px;
      }
    }
    .smart-list {
      margin-bottom: 4px;
    }
</style>
