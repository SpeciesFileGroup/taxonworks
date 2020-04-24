<template>
  <form class="gender">
    <block-layout
      anchor="gender"
      :spinner="saving">
      <h3 slot="header">Gender and form</h3>
      <div
        slot="body"
        v-if="taxon.id">
        <ul class="flex-wrap-column no_bullets">
          <li
            v-for="item in list">
            <label class="status-item">
              <input
                class="separate-right"
                type="radio"
                name="gender"
                @click="addEntry(item)"
                :checked="checkExist(item.type)"
                :value="item.type">
              <span>{{ item.name }}</span>
            </label>
          </li>
        </ul>
        <div v-if="inGroup('Species') && adjectiveOrParticiple">
          <div class="field">
            <label>Feminine </label><br>
            <input
              v-model="feminine"
              type="text">
          </div>
          <div class="field">
            <label>Masculine</label><br>
            <input
              v-model="masculine"
              type="text">
          </div>
          <div class="field">
            <label>Neuter</label><br>
            <input
              v-model="neuter"
              type="text">
          </div>
        </div>
        <list-entrys
          @delete="removeGender"
          @addCitation="setCitation"
          :list="getStatusGender"
          :display="['object_tag']"/>
      </div>
    </block-layout>
  </form>
</template>
<script>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import BlockLayout from './blockLayout.vue'
import ListEntrys from './listEntrys.vue'

import getRankGroup from '../helpers/getRankGroup'

export default {
  components: {
    BlockLayout,
    ListEntrys
  },
  data: function () {
    return {
      radioGender: 'masculine',
      list: [],
      filterList: ['gender', 'part of speech'],
      saving: false,
      types: {
        adjective: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective',
        participle: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle'
      }
    }
  },
  mounted: function () {
    this.getList()
  },
  computed: {
    getStatusGender () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter(function (item) {
        return (item.type.split('::')[1] == 'Latinized')
      })
    },
    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList]
    },
    adjectiveOrParticiple () {
      let find = this.$store.getters[GetterNames.GetTaxonStatusList].filter(function (item) {
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
      this.$store.dispatch(ActionNames.RemoveTaxonStatus, item)
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
        if(a.name > b.name) {
          return 1
        }
        if(a.name < b.name) {
          return -1
        }
        return 0
      })
    },
    checkExist: function (type) {
      return ((this.getStatusCreated.map(function (item) { return item.type })).indexOf(type) > -1)
    },
    searchExisting: function (type) {
      let list = this.list.map(function (item) { return item.type })

      return this.getStatusCreated.find(function (item) {
        if (list.indexOf(item.type) > -1) {
          return item
        }
      })
    },
    cleanNames() {
      this.masculine = null
      this.feminine = null
      this.neuter = null
    },
    addEntry: function (item) {
      let that = this
      let alreadyStored = this.searchExisting()

      this.saving = true
      if(!(item.type == this.types.participle || item.type == this.types.adjective)) {
        this.cleanNames()
      }
      let taxon = this.taxon
      
      delete taxon.feminine_name
      delete taxon.masculine_name
      delete taxon.neuter_name

      if (alreadyStored) {
        that.$store.dispatch(ActionNames.RemoveTaxonStatus, alreadyStored).then(response => {
          that.$store.dispatch(ActionNames.AddTaxonStatus, item).then(response => {
            that.$store.dispatch(ActionNames.UpdateTaxonName, that.taxon).then(function () {
              that.$store.dispatch(ActionNames.LoadTaxonName, taxon.id).then(function () {
                that.saving = false
              })
            })
          })
        })
      } else {
        that.$store.dispatch(ActionNames.AddTaxonStatus, item).then(response => {
          that.$store.dispatch(ActionNames.UpdateTaxonName, taxon).then(function () {
            setTimeout(function () {
              that.$store.dispatch(ActionNames.LoadTaxonName, taxon.id).then(function () {
                that.saving = false
              })
            }, 1000)
          })
        })
      }
    },
    applicableRank: function (list, type) {
      let found = list.find(function (item) {
        if (item == type) { return true }
      })
      return (!!found)
    },
    inGroup: function (group) {
      return (getRankGroup(this.taxon.rank_string) == group)
    }
  }
}
</script>
