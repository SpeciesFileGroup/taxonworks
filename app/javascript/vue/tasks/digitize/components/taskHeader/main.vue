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
      class="button normal-input btn-submit"
      type="button">Save
    </button>
  </div>
</template>

<script>
  import Autocomplete from '../../../../components/autocomplete.vue'

  export default {
    components: {
      Autocomplete
    }
  }
</script>
