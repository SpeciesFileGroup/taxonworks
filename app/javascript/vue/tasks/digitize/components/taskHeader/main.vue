<template>
  <div class="horizontal-left-content">
    <autocomplete
      url="/url"
      placeholder="Search"
      label="label_html"
      min="1"/>
    <button
      class="button normal-input btn-submit separate-left separate-right"
      type="button">Create, clone, and next
    </button>
    <button
      class="button normal-input btn-submit separate-left separate-right"
      type="button">Create, clone, and increment identifier
    </button>
    <button
      class="button normal-input button-submit separate-left separate-right"
      @click="saveDigitalization"
      type="button">Save
    </button>
    <button
      class="button normal-input button-default separate-left separate-right"
      @click="resetStore"
      type="button">New
    </button>
    |
    <span
      v-if="identifier.id"
      v-html="identifier.object_tag"/>
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
      saveDigitalization() {
        this.$store.dispatch(ActionNames.SaveDigitalization)
      },
      resetStore() {
        this.$store.commit(MutationNames.ResetStore)
      }
    }
  }
</script>
