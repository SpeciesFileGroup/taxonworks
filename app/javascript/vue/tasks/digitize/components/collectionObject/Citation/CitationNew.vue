<template>
  <fieldset class="fieldset">
    <legend>Source</legend>
    <div class="horizontal-left-content align-start separate-bottom">
      <smart-selector
        class="full_width"
        model="sources"
        klass="CollectionObject"
        target="CollectionObject"
        pin-section="Sources"
        pin-type="Source"
        v-model="source"
      />
      <v-lock
        class="margin-small-left"
        v-model="lockCOs"/>
    </div>
    <div
      v-if="source"
      class="field horizontal-left-content middle">
      <span v-html="source.object_tag"/>
      <button
        type="button"
        class="button circle-button btn-undo button-default"
        @click="source = undefined"/>
    </div>
    <div class="field">
      <input
        type="text"
        class="pages"
        placeholder="Pages"
        v-model="pages"
      >
      <label>
        <input
          type="checkbox">
        Is original
      </label>
    </div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="saveCitation"
      :disabled="!source">
      Add
    </button>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import makeCitationObject from '../../../const/citation'
import VLock from 'components/ui/VLock'

export default {
  components: {
    SmartSelector,
    VLock
  },

  props: {
    lock: {
      type: Boolean
    }
  },

  emits: [
    'update:lock',
    'onAdd'
  ],

  computed: {
    lockCOs: {
      get () {
        return this.lockValue
      },
      set (value) {
        this.$emit('update:lock', value)
      }
    }
  },

  data: () => ({
    source: undefined,
    pages: undefined,
    is_original: undefined
  }),

  methods: {
    saveCitation () {
      this.$emit('onAdd', {
        ...makeCitationObject(),
        citation_source_body: this.source.cached,
        pages: this.pages,
        source_id: this.source.id,
        is_original: this.is_original
      })

      this.source = undefined
      this.is_original = undefined
      this.pages = undefined
    }
  }
}
</script>
