<template>
  <navbar-component v-hotkey="shortcuts">
    <div class="flex-separate middle">
      <div
        class="horizontal-left-content"
        v-if="extract.id">
        <span v-html="extract.object_tag"/>
        <radial-annotator
          :global-id="extract.global_id"
        />
      </div>
      <span v-else>
        New
      </span>
      <div class="horizontal-right-content">
        <tippy
          v-if="unsavedChanges"
          animation="scale"
          placement="bottom"
          size="small"
          inertia
          arrow
          content="You have unsaved changes.">
          <span data-icon="warning"/>
        </tippy>

        <button
          type="button"
          class="button normal-input button-submit margin-small-right margin-small-left"
          @click="emitSave">
          Save
        </button>
        <button
          type="button"
          class="button normal-input button-default"
          @click="emitReset">
          New
        </button>
      </div>
    </div>
  </navbar-component>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { Tippy } from 'vue-tippy'
import NavbarComponent from 'components/layout/NavBar'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import platformKey from 'helpers/getMacKey.js'

export default {
  components: {
    NavbarComponent,
    Tippy,
    RadialAnnotator
  },

  emits: [
    'onSave',
    'onReset'
  ],

  computed: {
    extract () {
      return this.$store.getters[GetterNames.GetExtract]
    },

    lastChange () {
      return this.$store.getters[GetterNames.GetLastChange]
    },

    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    },

    unsavedChanges () {
      return this.lastChange > this.lastSave
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+s`] = this.emitSave
      keys[`${platformKey()}+n`] = this.emitReset

      return keys
    }
  },

  methods: {
    emitSave () {
      this.$emit('onSave')
    },

    emitReset () {
      this.$emit('onReset')
    }
  }
}
</script>
