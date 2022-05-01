<template>
  <block-layout
    anchor="original-combination"
    :warning="softValidation.length > 0"
    :spinner="!taxon.id"
    v-help.section.originalCombination.container>
    <template #header>
      <h3>Original combination and rank</h3>
    </template>
    <template #body>
      <div
        class="original-combination-picker">
        <form class="horizontal-left-content">
          <div class="button-current separate-right">
            <v-btn
              v-if="!existOriginalCombination"
              medium
              color="create"
              @click="addOriginalCombination()">
              Set as current
            </v-btn>
          </div>
          <div>
            <draggable
              class="flex-wrap-column"
              v-if="!existOriginalCombination"
              v-model="taxonOriginal"
              item-key="id"
              :group="{
                name: 'combination',
                put: isGenus,
                pull: true
              }"
              :animation="150"
              filter=".item-filter"
            >
              <template #item="{ element }">
                <div
                  class="horizontal-left-content middle item-draggable">
                  <input
                    type="text"
                    class="normal-input current-taxon"
                    :value="element.value.subject_object_tag"
                    disabled>
                  <span
                    class="handle button circle-button button-submit"
                    title="Press and hold to drag input"
                    data-icon="w_scroll-v"/>
                </div>
              </template>
            </draggable>
          </div>
        </form>
        <hr>
        <original-combination
          class="separate-top separate-bottom"
          nomenclature-group="Genus"
          @processed="saveTaxonName"
          @delete="saveTaxonName"
          @create="saveTaxonName"
          :disabled="!existOriginalCombination"
          :options="{
            animation: 150,
            group: {
              name: 'combination',
              put: isGenus,
              pull: false
            },
            filter: '.item-filter'
          }"
          :relationships="combinationRanks.genusGroup"/>
        <original-combination
          class="separate-top separate-bottom"
          v-if="!isGenus"
          nomenclature-group="Species"
          @processed="saveTaxonName"
          @delete="saveTaxonName"
          @create="saveTaxonName"
          :disabled="!existOriginalCombination"
          :options="{
            animation: 150,
            group: {
              name: 'combination',
              put: !isGenus,
              pull: false
            },
            filter: '.item-filter'
          }"
          :relationships="combinationRanks.speciesGroup"/>
        <div class="original-combination separate-top separate-bottom">
          <div class="flex-wrap-column rank-name-label">
            <label class="row capitalize"/>
          </div>
          <div
            v-if="existOriginalCombination"
            class="flex-separate middle">
            <span
              class="original-combination-name"
              v-html="taxon.original_combination"/>
            <span
              class="circle-button btn-delete"
              @click="removeAllCombinations()"/>
          </div>
        </div>
      </div>
    </template>
  </block-layout>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import Draggable from 'vuedraggable'
import OriginalCombination from './originalCombination.vue'
import BlockLayout from 'components/layout/BlockLayout'
import VBtn from 'components/ui/VBtn/index.vue'
import {
  originalCombinationType,
  combinationIcnType
} from '../const/combinationTypes'

export default {
  components: {
    Draggable,
    OriginalCombination,
    BlockLayout,
    VBtn
  },

  data () {
    return {
      taxonOriginal: []
    }
  },

  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    isGenus () {
      return (this.$store.getters[GetterNames.GetTaxon].rank_string.split('::')[2] === 'GenusGroup')
    },

    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].original_combination.list
    },

    originalCombinations () {
      return this.$store.getters[GetterNames.GetOriginalCombination]
    },

    existOriginalCombination () {
      const combinations = Object.values(this.originalCombinations)

      return !!combinations.find(combination => combination?.subject_taxon_name_id === this.taxon?.id)
    },

    types () {
      return Object.assign({}, this.combinationRanks.genusGroup, this.combinationRanks.speciesGroup)
    },

    combinationRanks () {
      return this.taxon.nomenclatural_code === 'icn'
        ? combinationIcnType
        : originalCombinationType
    }
  },

  watch: {
    existOriginalCombination: {
      handler (newVal, oldVal) {
        if (newVal == oldVal) return true
        this.createTaxonOriginal()
      },
      immediate: true
    },
    taxon: {
      handler (newVal, oldVal) {
        if(newVal.id && !oldVal.id) {
          this.createTaxonOriginal()
        }
      }
    }
  },
  methods: {
    saveTaxonName () {
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon).then(() => {
        this.$store.dispatch(ActionNames.LoadOriginalCombination, this.taxon.id)
      })
    },

    createTaxonOriginal () {
      this.taxonOriginal = [{
        value: {
          subject_taxon_name_id: this.taxon.id,
          subject_object_tag: this.taxon.name
        },
        id: this.taxon.id
      }]
    },

    removeAllCombinations () {
      if (window.confirm('Are you sure you want to remove all combinations?')) {
        const combinations = this.$store.getters[GetterNames.GetOriginalCombination]
        const deleteCombinations = Object.values(combinations).map(combination => this.$store.dispatch(ActionNames.RemoveOriginalCombination, combination))

        Promise.all(deleteCombinations).then(() => {
          this.saveTaxonName()
        })
      }
    },

    addOriginalCombination () {
      const promises = []

      this.$store.dispatch(ActionNames.AddOriginalCombination, {
        type: this.types[this.taxon.rank.toLowerCase()],
        id: this.taxon.id
      })

      this.taxon.ancestor_ids.forEach(item => {
        const rank = item[1].split('::')[3]
        const rankInType = this.types[rank?.toLowerCase()]

        if (rankInType) {
          promises.push(
            this.$store.dispatch(ActionNames.AddOriginalCombination, {
              type: rankInType,
              id: item[0]
            })
          )
        }
      })

      Promise.all(promises).then(() => {
        this.saveTaxonName()
      })
    },

    createCombination (id, rank) {
      const data = {
        type: this.types[rank],
        id: id
      }
      this.$store.dispatch(ActionNames.AddOriginalCombination, data)
    }
  }
}
</script>
<style lang="scss">
.original-combination-picker {
  .button-current {
    width: 100px;
  }
  .current-taxon {
    width: 400px;
  }
  .original-combination-name {
    margin-right:35px;
    width: 400px;
  }
  .handle {
    background-position: center;
    padding: 0px;
  }
}
</style>
