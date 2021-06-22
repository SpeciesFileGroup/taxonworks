<template>
  <fieldset>
    <legend>Source</legend>
    <smart-selector
      model="sources"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      ref="smartSelector"
      pin-section="Sources"
      pin-type="Source"
      v-model="assertedDistribution.citation.source">
      <template #footer>
        <div>
          <template v-if="assertedDistribution.citation.source">
            <div class="horizontal-left-content margin-small-top margin-small-bottom">
              <span data-icon="ok"/>
              <div>
                <span v-html="assertedDistribution.citation.source.object_tag"/>
                <pdf-button
                  v-for="item in documentation"
                  :key="item.id"
                  :pdf="item.document"/>
              </div>
              <span
                class="button circle-button btn-undo button-default"
                @click="unset"/>
            </div>
          </template>
          <div
            class="horizontal-left-content middle margin-medium-top">
            <label class="margin-small-right">
              <input
                class="pages"
                v-model="assertedDistribution.citation.pages"
                placeholder="Pages"
                type="text">
            </label>
            <ul class="no_bullets context-menu">
              <li>
                <label>
                  <input
                    type="checkbox"
                    v-model="assertedDistribution.citation.is_original">
                  Is original
                </label>
              </li>
              <li>
                <label>
                  <input
                    v-model="assertedDistribution.is_absent"
                    type="checkbox">
                  Is absent
                </label>
              </li>
            </ul>
          </div>
        </div>
      </template>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import PdfButton from 'components/pdfButton.vue'
import { Source } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    PdfButton
  },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  data: () => ({
    documentation: []
  }),

  computed: {
    assertedDistribution: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },
    source () {
      return this.assertedDistribution.citation.source
    }
  },

  watch: {
    source: {
      handler (newVal, oldVal) {
        if (newVal?.id) {
          if (newVal?.id !== oldVal?.id) {
            Source.documentation(newVal.id).then(response => {
              this.documentation = response.body
            })
          } else {
            this.documentation = []
          }
        }
      },
      deep: true
    }
  },

  methods: {
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.assertedDistribution.citation.source = undefined
    }
  }
}
</script>

<style scoped>
  .pages {
    widows: 80px;
  }
</style>
