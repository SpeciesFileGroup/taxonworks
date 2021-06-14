<template>
  <div class="original-combination">
    <div class="flex-wrap-column rank-name-label">
      <label
        v-for="(item, index) in orderRank"
        :class="{ 'new-position' : index == newPosition }"
        class="row capitalize">
        {{ item }}
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
        @update="onUpdate"
        @start="onStart">
        <template #item="{ element, index }">
          <div
            class="horizontal-left-content middle"
            v-if="!element.value">
            <autocomplete
              url="/taxon_names/autocomplete"
              label="label_html"
              min="2"
              :disabled="disabled"
              clear-after
              @getItem="addOriginalCombination($event.id, index)"
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
                <span v-html="element.value.subject_object_tag"/>
              </span>
            </div>
            <span
              class="handle button circle-button button-submit"
              title="Press and hold to drag input"
              data-icon="w_scroll-v"/>
            <radialAnnotator :global-id="element.value.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="removeCombination(element.value, index)"/>
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

    originalRelationship: {
      type: Object,
      default: () => ({})
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

  watch: {
    originalCombination () {
      this.loadOriginalCombinationList()
    }
  },

  created () {
    this.init()
  },

  methods: {
    init () {
      this.orderRank = Object.keys(this.relationships)
      this.originalTypes = Object.values(this.relationships)
    },

    loadOriginalCombinationList () {
      this.rankGroup = this.orderRank.map((rank, index) => ({
        name: rank,
        value: this.GetOriginal(rank),
        id: index
      }))
      this.copyRankGroup = this.rankGroup.splice()
    },

    addOriginalCombination (elementId, index) {
      const data = {
        type: this.originalTypes[index],
        id: elementId
      }
      return new Promise((resolve, reject) => {
        this.$store.dispatch(ActionNames.AddOriginalCombination, data).then(response => {
          this.rankGroup[index].value = response
          this.$emit('create')
          resolve(response)
        })
      })
    },

    GetOriginal (name) {
      const key = 'original_' + name

      return this.originalCombination[key] || undefined
    },

    removeCombination (value, index) {
      if (window.confirm('Are you sure you want to remove this combination?')) {
        this.$store.dispatch(ActionNames.RemoveOriginalCombination, value).then(response => {
          this.rankGroup[index] = response
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
      this.addOriginalCombination(this.rankGroup[index].value.subject_taxon_name_id, index).then(response => {
        this.$emit('create')
      })
    },

    onEnd (evt) {
      this.newPosition = -1
    },

    onStart (evt) {
      this.copyRankGroup = JSON.parse(JSON.stringify(this.rankGroup))
    },

    async onUpdate (evt) {
      const positionChanged = this.changedElementPositions()
      const deletePositions = positionChanged.filter(index => this.copyRankGroup[index].value)
      const createRelationships = positionChanged.filter(index => this.rankGroup[index].value)

      await this.destroyRelationships(deletePositions)
      this.createRelationships(createRelationships)
    },

    createRelationships (positions) {
      const promises = positions.map(position => this.addOriginalCombination(this.rankGroup[position].value.subject_taxon_name_id, position))

      Promise.all(promises).then(() => {
        this.$emit('create')
      })
    },

    changedElementPositions () {
      const changedPositions = []

      this.copyRankGroup.forEach((item, index) => {
        if (item.id !== this.rankGroup[index].id) {
          changedPositions.push(index)
        }
      })

      return changedPositions
    },

    destroyRelationships (positions) {
      return new Promise((resolve, reject) => {
        const promises = positions.map(position => this.$store.dispatch(ActionNames.RemoveOriginalCombination, this.copyRankGroup[position].value))

        Promise.all(promises).then(() => {
          resolve(promises)
        })
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
