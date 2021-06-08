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
        item-key="id"
        :group="options.group"
        :animation="options.animation"
        :filter="options.filter"
        @end="onEnd"
        @add="onAdd"
        @autocomplete="searchForChanges(rankGroup,copyRankGroup)"
        @update="onUpdate"
        :move="onMove">
        <template #item="{ element }">
          <div
            class="horizontal-left-content middle"
            v-if="(GetOriginal(element.name).length == 0)">
            <autocomplete
              url="/taxon_names/autocomplete"
              label="label_html"
              min="2"
              :disabled="disabled"
              clear-after
              @getItem="element.autocomplete = $event; searchForChanges(rankGroup,copyRankGroup)"
              :add-params="{ type: 'Protonym', 'nomenclature_group[]': nomenclatureGroup }"
              param="term"/>
            <span
              class="handle button circle-button button-submit"
              title="Press and hold to drag input"
              data-icon="w_scroll-v"/>
          </div>
          <div
            class="original-combination-item horizontal-left-content middle"
            v-else>
            <div>
              <span class="vue-autocomplete-input normal-input combination middle">
                <span v-html="GetOriginal(element.name).subject_object_tag"/>
              </span>
            </div>
            <span
              class="handle button circle-button button-submit"
              title="Press and hold to drag input"
              data-icon="w_scroll-v"/>
            <radialAnnotator :global-id="GetOriginal(element.name).global_id"/>
            <span
              class="circle-button btn-delete"
              @click="removeCombination(GetOriginal(element.name))"/>
          </div>
        </template>
      </draggable>
    </div>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import Autocomplete from 'components/ui/Autocomplete.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import AjaxCall from 'helpers/ajaxCall'
import Draggable from 'vuedraggable'

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
      default: () => {
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

  emits: [
    'create',
    'delete',
    'processed'
  ],

  data () {
    return {
      expanded: true,
      rankGroup: [],
      orderRank: [],
      copyRankGroup: undefined,
      originalTypes: [],
      newPosition: -1
    }
  },

  created () {
    this.init()
  },

  watch: {
    taxon: {
      handler (taxon) {
        if (!taxon.id) return true
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
    init () {
      let inc = 0
      for (const key in this.relationships) {
        const combination = {
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
    searchForChanges (newVal, copyOld) {
      newVal.forEach((element, index) => {
        if (JSON.stringify(newVal[index]) != JSON.stringify(copyOld[index])) {
          if (JSON.stringify(newVal[index].id) == JSON.stringify(copyOld[index].id)) {
            if (JSON.stringify(newVal[index].autocomplete) != JSON.stringify(copyOld[index].autocomplete)) {
              if (newVal[index].autocomplete) {
                this.addOriginalCombination(newVal[index].autocomplete.id, index).then(response => {
                  this.$emit('create', response)
                })
                this.copyRankGroup = JSON.parse(JSON.stringify(newVal))
              }
            }
          }
        }
      })
    },

    setNewCombinations () {
      this.rankGroup.forEach((element, index) => {
        this.rankGroup[index].value = this.GetOriginal(this.rankGroup[index].name)
      })
    },

    processChange (positions) {
      const copyCombinations = []
      const allDelete = []

      positions.forEach((element) => {
        copyCombinations.push(JSON.parse(JSON.stringify(this.rankGroup[element])))
        if (this.rankGroup[element].value) {
          allDelete.push(
            this.$store.dispatch(ActionNames.RemoveOriginalCombination, this.rankGroup[element].value)
          )
        }
      })
      Promise.all(allDelete).then(() => {
        const allCreated = []

        positions.forEach((element, index) => {
          if (copyCombinations[index].value) {
            allCreated.push(
              this.addOriginalCombination(copyCombinations[index].value.subject_taxon_name_id, element, this.originalTypes)
            )
          }
        })
        Promise.all(allDelete).then(() => {
          this.$emit('processed', true)
        })
      })
    },
    addOriginalCombination (elementId, index) {
      const data = {
        type: this.originalTypes[index],
        id: elementId
      }
      return new Promise((resolve, reject) => {
        this.$store.dispatch(ActionNames.AddOriginalCombination, data).then(response => {
          resolve(response)
        })
      })
    },
    GetOriginal (name) {
      const key = 'original_' + name
      return this.originalCombination[key] || ''
    },

    removeCombination (value) {
      if(window.confirm('Are you sure you want to remove this combination?')) {
        this.$store.dispatch(ActionNames.RemoveOriginalCombination, value).then(response => {
          this.$emit('delete', response)
        })
      }
    },

    onMove (evt) {
      this.newPosition = evt.draggedContext.futureIndex
      return !evt.related.classList.contains('item-filter')
    },

    onAdd (evt) {
      let index = evt.newIndex

      if ((this.rankGroup.length - 1) === evt.newIndex) {
        this.rankGroup.splice((evt.newIndex - 1), 1)
        index = evt.newIndex - 1
      }

      this.rankGroup.splice((evt.newIndex + 1), 1)
      this.updateNames()
      this.addOriginalCombination(this.rankGroup[index].value.subject_taxon_name_id, index).then(response => {
        this.$emit('create')
      })
    },
    onEnd (evt) {
      this.newPosition = -1
    },
    onUpdate (evt) {
      const newVal = this.rankGroup
      const copyOld = this.copyRankGroup
      const positions = []

      newVal.forEach((element, index) => {
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

    updateNames (group) {
      this.rankGroup.forEach((element, index) => {
        this.rankGroup[index].name = this.orderRank[index]
      })
    },

    loadCombinations (id) {
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
