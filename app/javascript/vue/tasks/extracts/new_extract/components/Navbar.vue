<template>
  <navbar-component>
    <div class="flex-separate middle">
      <span
        v-if="extract.id"
        v-html="extract.object_tag"/>
      <span v-else>
        New
      </span>
      <div class="horizontal-right-content">
        <tippy-component
          v-if="unsavedChanges"
          animation="scale"
          placement="bottom"
          size="small"
          inertia
          arrow
          content="You have unsaved changes.">
          <template slot="trigger">
            <span data-icon="warning"/>
          </template>
        </tippy-component>

        <button
          type="button"
          class="button normal-input button-submit margin-small-right margin-small-left"
          v-shortkey="[OSKey, 's']"
          @shortkey="$emit('onSave')"
          @click="$emit('onSave')">
          Save
        </button>
        <button
          type="button"
          class="button normal-input button-default"
          v-shortkey="[OSKey, 'n']"
          @shortkey="$emit('onReset')"
          @click="$emit('onReset')">
          New
        </button>
      </div>
    </div>
  </navbar-component>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { TippyComponent } from 'vue-tippy'
import NavbarComponent from 'components/navBar'
import OSKey from 'helpers/getMacKey.js'

export default {
  components: {
    NavbarComponent,
    TippyComponent
  },

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

    OSKey
  }
}
</script>
