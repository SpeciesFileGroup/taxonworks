<template>
  <div class="horizontal-left-content">
    <autocomplete
      url="/url"
      placeholder="Search"
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
  </div>
</template>

<script>
  import Autocomplete from '../../../../components/autocomplete.vue'
  import { ActionNames } from '../../store/actions/actions.js'

  export default {
    components: {
      Autocomplete
    },
    methods: {
      saveDigitalization() {
        this.$store.dispatch(ActionNames.SaveDigitalization)
      }
    }
  }
</script>
