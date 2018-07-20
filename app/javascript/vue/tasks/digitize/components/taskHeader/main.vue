<template>
  <div class="horizontal-left-content">
    <autocomplete
      url="/url"
      placeholder="Search"
      label="label_html"
      min="1"/>
    <button
      class="button normal-input btn-submit"
      type="button">Create, clone, and next
    </button>
    <button
      class="button normal-input btn-submit"
      type="button">Create, clone, and increment identifier
    </button>
    <button
      class="button normal-input button-submit"
      @click="saveDigitalization"
      type="button">Save
    </button>
    |
    <span
      v-if="identifier.id"
      v-html="identifier.object_tag"/>
  </div>
</template>

<script>
  import Autocomplete from '../../../../components/autocomplete.vue'
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
      }
    }
  }
</script>
