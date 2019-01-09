<template>
  <div class="panel content separate-bottom">
    <div class="middle flex-separate">
      <div class="horizontal-left-content">
        <autocomplete
          url="/url"
          placeholder="Search"
          label="label_html"
          min="1"/>
        <span
          class="separate-left"
          v-if="identifier.id"
          v-html="identifier.object_tag"/>
      </div>
      <div class="horizontal-left-content">
        <button
          class="button normal-input button-submit separate-left separate-right"
          @click="saveDigitalization"
          v-shortkey="[getMacKey(), 's']"
          @shortkey="saveDigitalization"
          type="button">Save
        </button>
        <div
          v-shortkey="[getMacKey(), 'r']"
          @shortkey="resetStore"
          @click="resetStore">
          <span data-icon="reset"/>
          <span>Reset</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Autocomplete from '../../../../components/autocomplete.vue'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import { ActionNames } from '../../store/actions/actions.js'
  import { GetterNames } from '../../store/getters/getters.js'

  export default {
    components: {
      Autocomplete
    },
    computed: {
      identifier() {
        return this.$store.getters[GetterNames.GetIdentifier]
      }
    },
    methods: {
      getMacKey: function () {
        return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
      },
      saveDigitalization() {
        this.$store.dispatch(ActionNames.SaveDigitalization)
      },
      resetStore() {
        this.$store.commit(MutationNames.ResetStore)
      }
    }
  }
</script>
