<template>
  <div class="original-combination">
    <div class="flex-wrap-column rank-name-label">
      <label
        v-for="(item, index) in rankGroup"
        :class="{ 'new-position' : index == newPosition }"
        class="row capitalize">
        {{ item.name }}
      </label>
    </div>
    <div>
      <draggable
        class="flex-wrap-column"
        v-model="rankGroup"
        :options="options"
        @end="onEnd"
        @add="onAdd"
        @autocomplete="searchForChanges(rankGroup,copyRankGroup)"
        @update="onUpdate"
        :move="onMove">
        <div
          v-for="(item, index) in rankGroup"
          class="horizontal-left-content middle"
          v-if="(GetOriginal(rankGroup[index].name).length == 0)"
          :key="item.id">
          <autocomplete
            url="/taxon_names/autocomplete"
            label="label_html"
            min="2"
            :disabled="disabled"
            clear-after
            @getItem="item.autocomplete = $event; searchForChanges(rankGroup,copyRankGroup)"
            event-send="autocomplete"
            :add-params="{ type: 'Protonym', 'nomenclature_group[]': nomenclatureGroup }"
            param="term"/>
          <span
            class="handle button circle-button button-submit"
            title="Press and hold to drag input"
            data-icon="w_scroll-v"/>
        </div>
        <div
          class="original-combination-item horizontal-left-content middle"
          v-else
          :key="item.id">
          <div>
            <span class="vue-autocomplete-input normal-input combination middle">
              <span v-html="GetOriginal(rankGroup[index].name).subject_object_tag"/>
            </span>
          </div>
          <span
            class="handle button circle-button button-submit"
            title="Press and hold to drag input"
            data-icon="w_scroll-v"/>
          <radialAnnotator :global-id="GetOriginal(rankGroup[index].name).global_id"/>
          <span
            class="circle-button btn-delete"
            @click="removeCombination(GetOriginal(rankGroup[index].name))"/>
        </div>
      </draggable>
    </div>
  </div>
</template>
<script>

import Draggable from 'vuedraggable'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import Autocomplete from 'components/ui/Autocomplete.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    RadialAnnotator,
    Autocomplete,
    Draggable
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    originalCombination () {
      return this.$store.getters[GetterNames.GetOriginalCombination]
    }
  },
  props: {
    disabled: {
      type: Boolean,
      default: false
    },
    relationships: {
      type: Object,
      required: true
    },
    nomenclatureGroup: {
      type: String,
      required: true
    },
    options: {
      type: Object,
      default: function () {
        return {
          animation: 150,
          group: {
            name: 'combination',
            put: true,
            pull: true
          },
          filter: '.item-filter'
        }
      }
    }
  },
  data: function () {
    return {
      expanded: true,
      rankGroup: [],
      orderRank: [],
      copyRankGroup: undefined,
      originalTypes: [],
      newPosition: -1
    }
  },
  created: function () {
    this.init()
  },
  watch: {
    taxon: {
      handler: function (taxon) {
        if (taxon.id == undefined) return true
        this.loadCombinations(taxon.id)
      },
      immediate: true
    },
    originalCombination: {
      handler: function (newVal, oldVal) {
        if (JSON.stringify(newVal) == JSON.stringify(this.copyRankGroup)) return true
        this.setNewCombinations()
      },
      deep: true
    }
  },
  methods: {
    init: function () {
      let inc = 0
      for (var key in this.relationships) {
        let combination = {
          name: key,
          value: '',
          show: true,
          autocomplete: undefined,
          id: inc
        }
        this.orderRank.push(key)
        this.rankGroup.push(combination)
        this.originalTypes.push(this.relationships[key])
        inc++
      }
      this.copyRankGroup = JSON.parse(JSON.stringify(this.rankGroup))
    },
    searchForChanges: function (newVal, copyOld) {
      var that = this
      newVal.forEach(function (element, index) {
        if (JSON.stringify(newVal[index]) != JSON.stringify(copyOld[index])) {
          if (JSON.stringify(newVal[index].id) == JSON.stringify(copyOld[index].id)) {
            if (JSON.stringify(newVal[index].autocomplete) != JSON.stringify(copyOld[index].autocomplete)) {
              if (newVal[index].autocomplete) {
                that.addOriginalCombination(newVal[index].autocomplete.id, index).then(response => {
                  that.$emit('create', response)
                })
                that.copyRankGroup = JSON.parse(JSON.stringify(newVal))
              }
            }
          }
        }
      })
    },
    setNewCombinations: function () {
      var that = this
      this.rankGroup.forEach(function (element, index) {
        that.rankGroup[index].value = that.GetOriginal(that.rankGroup[index].name)
      })
    },
    processChange: function (positions) {
      var that = this
      var copyCombinations = []
      let allDelete = []

      positions.forEach(function (element, index) {
        copyCombinations.push(JSON.parse(JSON.stringify(that.rankGroup[element])))
        if (that.rankGroup[element].value != '') {
          allDelete.push(
            that.$store.dispatch(ActionNames.RemoveOriginalCombination, that.rankGroup[element].value).then(response => {
              return true
            }, response => { return true })
          )
        }
      })
      Promise.all(allDelete).then(response => {
        let allCreated = []

        positions.forEach(function (element, index) {
          if (copyCombinations[index].value != '') {
            allCreated.push(
              that.addOriginalCombination(copyCombinations[index].value.subject_taxon_name_id, element, that.originalTypes).then(response => {
                return true
              })
            )
          }
        })
        Promise.all(allDelete).then(response => {
          that.$emit('processed', true)
        })
      })
    },
    addOriginalCombination: function (elementId, index) {
      var that = this
      var data = {
        type: this.originalTypes[index],
        id: elementId
      }
      return new Promise(function (resolve, reject) {
        that.$store.dispatch(ActionNames.AddOriginalCombination, data).then(response => {
          resolve(response)
        })
      })
    },
    GetOriginal: function (name) {
      let key = 'original_' + name
      return (this.originalCombination.hasOwnProperty(key) ? this.originalCombination[key] : '')
    },

    removeCombination: function (value) {
      if(window.confirm('Are you sure you want to remove this combination?')) {
        let that = this

        this.$store.dispatch(ActionNames.RemoveOriginalCombination, value).then(response => {
          that.$emit('delete', response)
        })
      }
    },
    onMove: function (evt) {
      this.newPosition = evt.draggedContext.futureIndex
      return !evt.related.classList.contains('item-filter')
    },
    onAdd: function (evt) {
      let that = this
      let index = evt.newIndex
      if ((this.rankGroup.length - 1) == evt.newIndex) {
        this.rankGroup.splice((evt.newIndex - 1), 1)
        index = evt.newIndex - 1
      }
      this.rankGroup.splice((evt.newIndex + 1), 1)
      this.updateNames()
      this.addOriginalCombination(this.rankGroup[index].value.subject_taxon_name_id, index).then(response => {
        that.$emit('create')
      })
    },
    onEnd: function (evt) {
      this.newPosition = -1
    },
    onUpdate: function (evt) {
      let newVal = this.rankGroup
      let copyOld = this.copyRankGroup
      let positions = []
      newVal.forEach(function (element, index) {
        if (JSON.stringify(newVal[index]) != JSON.stringify(copyOld[index])) {
          if (JSON.stringify(newVal[index].id) != JSON.stringify(copyOld[index].id)) {
            positions.push(index)
          }
        }
      })
      if (positions.length) {
        this.copyRankGroup = JSON.parse(JSON.stringify(newVal))
        this.setNewCombinations()
        this.updateNames()
        this.processChange(positions)
      }
    },
    updateNames: function (group) {
      var that = this
      this.rankGroup.forEach(function (element, index) {
        that.rankGroup[index].name = that.orderRank[index]
      })
    },
    loadCombinations: function (id) {
      AjaxCall('get', `/taxon_names/${id}/original_combination.json`).then(response => {
        this.$store.commit(MutationNames.SetOriginalCombination, response.body)
      })
    }
  }
}
</script>
<style lang="scss">
  .original-combination {
    .new-position {
      color: red;
      font-weight: 900;
    }
    .original-combination-item {
      min-height: 40px
    }
    .vue-autocomplete-input {
      min-height: 28px;
      min-width: 400px;
      max-width: 500px;
    }
    .combination {
      z-index:1;
      background-color: #F5F5F5;
    }
  }
</style>
