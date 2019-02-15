<template>
  <div class="panel content panel-section">
    <h2>Staged image</h2>
    <div class="flexbox">
      <mode-component />
      <pattern-component
        v-model="pattern"
        :patterns="extractionPatterns"
      />
      <color-component
        :colors="colors"
        v-model="sqed_depiction_attributes.boundary_color"
      />
      <component
        v-if="componentExist"
        :is="layoutName"
        :layout-types="metadata.layout_section_types"
        v-model="sqed_depiction_attributes.metadata_map"
        :style="{ 'background-color': sqed_depiction_attributes.boundary_color }"
        style="border: 4px solid gray"
      />
    </div>
  </div>
</template>

<script>

import ModeComponent from './mode'
import PatternComponent from './pattern'
import { GetSqedMetadata } from '../../request/resources.js'
import ColorComponent from './color'

import EqualCrossLayout from './layouts/equal_cross'
import CrossLayout from './layouts/cross'
import RightTLayout from './layouts/right_t'
import VerticalOffsetCrossLayout from './layouts/vertical_offset_cross'
import SevenSlotLayout from './layouts/seven_slot'
import LepStageLayout from './layouts/lep_stage'

export default {
  components: {
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
        this.sqed_depiction_attributes = Object.assign(this.sqed_depiction_attributes, value)
      }
    }
  },
  data() {
    return {
      metadata: {},
      sqed_depiction_attributes: {
        id: undefined,
        boundary_color: undefined,
        boundary_finder: undefined,
        has_border: undefined, 
        layout: undefined,
        metadata_map: []
      }
    }
  },
  mounted() {
    GetSqedMetadata().then(response => {
      this.metadata = response.body
    })
  }
}
</script>