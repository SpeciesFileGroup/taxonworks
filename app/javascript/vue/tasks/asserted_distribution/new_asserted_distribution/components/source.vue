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
      v-model="citation.source">
      <div class="flex-separate middle margin-medium-bottom">
        <label>
          <input
            type="checkbox"
            v-model="citation.is_original">
          Is original
        </label>
        <label>
          Pages:
          <input
            class="pages"
            v-model="citation.pages"
            placeholder="Pages"
            type="text">
        </label>
      </div>
      <template v-if="citation.source">
        <p class="horizontal-left-content">
          <span data-icon="ok"/>
          <span v-html="citation.source.object_tag"/>
          <span
            class="button circle-button btn-undo button-default"
            @click="unset"/>
        </p>
      </template>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    citation: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  methods: {
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.citation.source = undefined
    }
  }
}
</script>

<style scoped>
  .pages {
    widows: 80px;
  }
</style>

