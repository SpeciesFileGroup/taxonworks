<template>
  <block-layout
    anchor="gender"
    :spinner="saving || !taxon.id"
  >
    <template #header>
      <h3>Gender and form</h3>
    </template>
    <template
      #body
      v-if="taxon.id">
      <ul class="flex-wrap-column no_bullets">
        <template v-for="item in list">
          <li>
            <label class="status-item">
              <input
                class="separate-right"
                type="radio"
                name="gender"
                @click="addEntry(item)"
                :checked="checkExist(item.type)"
                :value="item.type"
              >
              <span>{{ item.name }}</span>
            </label>
          </li>
        </template>
      </ul>
      <div v-if="inSpeciesGroup && adjectiveOrParticiple">
        <div class="field label-above">
          <label>Masculine</label>
          <input
            v-model="masculine"
            type="text"
          >
        </div>
        <div class="field label-above">
          <label>Feminine </label>
          <input
            v-model="feminine"
            type="text"
          >
        </div>
        <div class="field label-above">
          <label>Neuter</label>
          <input
            v-model="neuter"
            type="text"
          >
        </div>
      </div>
      <list-entrys
        @delete="removeGender"
        @addCitation="setCitation"
        :list="getStatusGender"
        :display="['object_tag']"
      />
    </template>
  </block-layout>
</template>
<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import BlockLayout from 'components/layout/BlockLayout.vue'
import ListEntrys from './listEntrys.vue'

import getRankGroup from '../helpers/getRankGroup'

export default {
  components: {
    BlockLayout,
    ListEntrys
  },
  data () {
    return {
      list: [],
      filterList: ['gender', 'part of speech'],
      saving: false,
      types: {
        adjective: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective',
        participle: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle'
      },
      sortOrder: [
        'masculine',
        'feminine',
        'neuter',
        'noun in apposition',
        'noun in genitive case',
        'adjective',
        'participle'
      ]
    }
  },
  mounted () {
    this.getList()
  },
  computed: {
    inSpeciesGroup () {
      const group = getRankGroup(this.taxon.rank_string)
      return (group === 'SpeciesAndInfraspecies' || group === 'Species')
    },
    getStatusGender () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter(function (item) {
        return (item.type.split('::')[1] == 'Latinized')
      })
    },
    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList]
    },
    adjectiveOrParticiple () {
      const find = this.$store.getters[GetterNames.GetTaxonStatusList].filter(function (item) {
        return (item.type == 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective' ||
          item.type == 'TaxonNameClassification::Latinized::PartOfSpeech::Participle')
      })
      return (!!find.length)
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    getStatusList: function () {
      return this.$store.getters[GetterNames.GetStatusList].latinized.all
    },
    feminine: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonFeminine]
      },
      set (value) {
        this.$store.commit(MutationNames.UpdateLastChange)
        this.$store.commit(MutationNames.SetTaxonFeminine, value)
      }
    },
    masculine: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonMasculine]
      },
      set (value) {
        this.$store.commit(MutationNames.UpdateLastChange)
        this.$store.commit(MutationNames.SetTaxonMasculine, value)
      }
    },
    neuter: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonNeuter]
      },
      set (value) {
        this.$store.commit(MutationNames.UpdateLastChange)
        this.$store.commit(MutationNames.SetTaxonNeuter, value)
      }
    }
  },
  methods: {
    removeGender: function (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonStatus, item).then(() => {
        this.taxon.feminine_name = null
        this.taxon.masculine_name = null
        this.taxon.neuter_name = null
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      })
    },
    setCitation: function (item) {
      this.$store.dispatch(ActionNames.UpdateClassification, item)
    },
    getList: function () {
      for (var key in this.getStatusList) {
        if (this.applicableRank(this.getStatusList[key].applicable_ranks, this.taxon.rank_string)) {
          if (this.filterList.indexOf(this.getStatusList[key].name) < 0) { this.list.push(this.getStatusList[key]) }
        }
      }

      this.list.sort((a, b) => {
        return this.sortOrder.indexOf(a.name) - this.sortOrder.indexOf(b.name)
      })
    },
    checkExist: function (type) {
      return ((this.getStatusCreated.map(function (item) { return item.type })).indexOf(type) > -1)
    },
    searchExisting: function (type) {
      const list = this.list.map(function (item) { return item.type })

      return this.getStatusCreated.find(function (item) {
        if (list.indexOf(item.type) > -1) {
          return item
        }
      })
    },
    cleanNames () {
      this.masculine = null
      this.feminine = null
      this.neuter = null
    },
    async addEntry (item) {
      const alreadyStored = this.searchExisting()
      const taxon = Object.assign({}, this.taxon)

      this.saving = true
      if (alreadyStored) {
        await this.$store.dispatch(ActionNames.RemoveTaxonStatus, alreadyStored)
      }

      if (taxon.feminine_name || taxon.masculine_name || taxon.neuter_name) {
        taxon.feminine_name = null
        taxon.masculine_name = null
        taxon.neuter_name = null
        await this.$store.dispatch(ActionNames.UpdateTaxonName, taxon)
      }

      this.$store.dispatch(ActionNames.AddTaxonStatus, item).then(() => {
        taxon.feminine_name = undefined
        taxon.masculine_name = undefined
        taxon.neuter_name = undefined
        this.$store.dispatch(ActionNames.UpdateTaxonName, taxon).then(() => {
          this.saving = false
        })
      })
    },
    applicableRank: function (list, type) {
      return !!list.find((item) => item === type)
    },
    inGroup: function (group) {
      return (getRankGroup(this.taxon.rank_string) === group)
    }
  }
}
</script>
