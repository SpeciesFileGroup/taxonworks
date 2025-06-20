<template>
  <BlockLayout>
    <template #header>
      <h3>Staged image</h3>
    </template>
    <template #body>
      <spinner-component
        :show-spinner="false"
        legend="Clear the list of depict some or select only one collection object."
        v-if="disabledSection"
      />

      <div class="flex-separate">
        <pattern-component
          v-model="pattern"
          :patterns="extractionPatterns"
        />
        <div>
          <color-component
            :colors="colors"
            :disabled="isNone"
            v-model="sqed_depiction_attributes.boundary_color"
          />
          <div class="separate-top">
            <label>
              <input
                v-model="sqed_depiction_attributes.has_border"
                type="checkbox"
                :disabled="isNone"
              />
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
            :style="{
              'background-color': sqed_depiction_attributes.boundary_color
            }"
            :class="{ hasBorder: sqed_depiction_attributes.has_border }"
          />
          <div
            v-else
            class="panel horizontal-center-content middle pattern-box"
          >
            <h3>Choose a pattern</h3>
          </div>
        </div>
      </div>
      <div
        class="margin-large-top separate-bottom horizontal-left-content align-start"
      >
        <new-object />
        <div class="full_width separate-left">
          <tags-component class="panel-section" />
          <data-attributes class="panel-section separate-top" />
        </div>
      </div>
      <div class="separate-top">
        <button
          type="button"
          class="button normal-input button-default"
          @click="resetSqed"
        >
          Reset
        </button>
      </div>
    </template>
  </BlockLayout>
</template>

<script>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PatternComponent from './pattern'
import ColorComponent from './color'
import NewObject from './newObject'

import EqualCrossLayout from './layouts/equal_cross'
import CrossLayout from './layouts/cross'
import RightTLayout from './layouts/right_t'
import LeftTLayout from './layouts/left_t'
import HorizontalSplitLayout from './layouts/horizontal_split'
import HorizontalOffsetCrossLayout from './layouts/horizontal_offset_cross'
import VerticalOffsetCrossLayout from './layouts/vertical_offset_cross'
import SevenSlotLayout from './layouts/seven_slot'
import LepStageLayout from './layouts/lep_stage'
import LepStage2Layout from './layouts/lep_stage2'
import TLayout from './layouts/t.vue'
import InvertedTLayout from './layouts/t_inverted.vue'
import VerticalSplitLayout from './layouts/vertical_split'
import NoneLayout from './layouts/none.vue'
import SpinnerComponent from '@/components/ui/VSpinner'

import TagsComponent from './tags'
import DataAttributes from '../../dataAttributes'

import { GetterNames } from '../../../store/getters/getters.js'
import { MutationNames } from '../../../store/mutations/mutations.js'
import { SqedDepiction } from '@/routes/endpoints'

export default {
  components: {
    NewObject,
    PatternComponent,
    ColorComponent,
    EqualCrossLayout,
    CrossLayout,
    VerticalOffsetCrossLayout,
    RightTLayout,
    SevenSlotLayout,
    LepStageLayout,
    HorizontalSplitLayout,
    HorizontalOffsetCrossLayout,
    VerticalSplitLayout,
    SpinnerComponent,
    TagsComponent,
    DataAttributes,
    LepStage2Layout,
    LeftTLayout,
    TLayout,
    InvertedTLayout,
    NoneLayout,
    BlockLayout
  },

  computed: {
    componentExist() {
      return !!this.$options.components[this.layoutName]
    },

    disabledSection() {
      const objects = this.$store.getters[GetterNames.GetObjectsForDepictions]
      return (
        objects.length > 1 ||
        objects.find((item) => item.base_class !== 'CollectionObject')
      )
    },

    layoutName() {
      return this.sqed_depiction_attributes.layout
        ? `${this.sqed_depiction_attributes.layout
            .toPascalCase()
            .replace(/_/g, '')}Layout`
        : undefined
    },

    extractionPatterns() {
      return this.metadata?.extraction_patterns || {}
    },

    colors() {
      return this.metadata?.boundary_colors || []
    },

    isNone() {
      return this.layoutName === 'NoneLayout'
    },

    pattern: {
      get() {
        return this.sqed_depiction_attributes
      },
      set(value) {
        value.boundary_finder = 'Sqed::BoundaryFinder::ColorLineFinder'
        this.sqed_depiction_attributes = Object.assign(
          this.sqed_depiction_attributes,
          value
        )
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
      metadata: {}
    }
  },

  watch: {
    isNone(newVal) {
      if (newVal) {
        this.sqed_depiction_attributes.boundary_color = undefined
        this.sqed_depiction_attributes.has_border = undefined
      }
    }
  },

  created() {
    SqedDepiction.metadata().then(({ body }) => {
      const metadata = body

      Object.assign(metadata.extraction_patterns, {
        none: {
          layout: 'stage',
          boundary_finder: {},
          metadata_map: {
            0: 'none'
          }
        }
      })

      this.metadata = metadata
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
  border: 4px solid gray;
}
.pattern-box {
  height: 200px;
  width: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid var(--border-color);
  border-radius: 3px;
}
</style>
