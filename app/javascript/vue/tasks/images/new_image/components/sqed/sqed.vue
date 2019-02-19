<template>
  <div class="panel content panel-section">
    <h2>Staged image</h2>
    <div class="flexbox">
      <div class="separate-right">
        <mode-component class="separate-bottom"/>
        <new-object class="separate-top"/>
      </div>
      <pattern-component
        class="separate-left"
        v-model="pattern"
        :patterns="extractionPatterns"
      />
      <div>
        <color-component
          :colors="colors"
          v-model="sqed_depiction_attributes.boundary_color"
        />
        <div class="separate-top">
          <label>
            <input
              v-model="sqed_depiction_attributes.has_border"
              type="checkbox"
            >
            Has border
          </label>
        </div>
      </div>
      <div>
        <component
          v-if="componentExist"
          :is="layoutName"
          :layout-types="metadata.layout_section_types"
          v-model="sqed_depiction_attributes.metadata_map"
          :style="{ 'background-color': sqed_depiction_attributes.boundary_color }"
          :class="{ hasBorder: sqed_depiction_attributes.has_border }"
        />
      </div>
    </div>
    <div class="separate-top">
      <button
        type="button"
        class="button normal-input button-default"
        @click="resetSqed">
        Reset
      </button>
    </div>
  </div>
</template>

<script>

import ModeComponent from './mode'
import PatternComponent from './pattern'
import ColorComponent from './color'
import NewObject from './newObject'

import EqualCrossLayout from './layouts/equal_cross'
import CrossLayout from './layouts/cross'
import RightTLayout from './layouts/right_t'
import VerticalOffsetCrossLayout from './layouts/vertical_offset_cross'
import SevenSlotLayout from './layouts/seven_slot'
import LepStageLayout from './layouts/lep_stage'

import { GetSqedMetadata } from '../../request/resources.js'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    NewObject,
    ModeComponent,
    PatternComponent,
    ColorComponent,
    EqualCrossLayout,
    CrossLayout,
    VerticalOffsetCrossLayout,
    RightTLayout,
    SevenSlotLayout,
    LepStageLayout
  },
  computed: {
    componentExist() {
      return this.$options.components[this.layoutName] ? true : false
    },
    layoutName() {
      if(this.sqed_depiction_attributes.layout) {
        return `${this.sqed_depiction_attributes.layout.toPascalCase().replace(/_/g, '')}Layout`
      }
      return undefined
    },
    extractionPatterns() {
      let exist = this.metadata.hasOwnProperty('extraction_patterns')
      return (exist ? this.metadata.extraction_patterns : {})
    },
    colors() {
      let exist = this.metadata.hasOwnProperty('boundary_colors')
      return (exist ? this.metadata.boundary_colors : [])
    },
    pattern: {
      get() {
        return this.sqed_depiction_attributes
      },
      set(value) {
        value.boundary_finder = 'Sqed::BoundaryFinder::ColorLineFinder'
        this.sqed_depiction_attributes = Object.assign(this.sqed_depiction_attributes, value)
      }
    },
    sqed_depiction_attributes: {
      get() {
        return this.$store.getters[GetterNames.GetSqed]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSqed, value)
      }
    }
  },
  data() {
    return {
      metadata: {},
    }
  },
  mounted() {
    GetSqedMetadata().then(response => {
      this.metadata = response.body
    })
  },
  methods: {
    resetSqed() {
      this.$store.commit(MutationNames.SetSqed, {
        id: undefined,
        boundary_color: undefined,
        boundary_finder: undefined,
        has_border: false, 
        layout: undefined,
        metadata_map: []
      })
    }
  }
}
</script>

<style scoped>
  .hasBorder {
    border: 4px solid gray
  }
</style>
