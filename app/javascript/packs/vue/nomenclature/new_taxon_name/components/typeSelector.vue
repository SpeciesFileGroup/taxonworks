<template>
  <form class="content" v-if>
    <h3>Type</h3>
    <div class="field">
      <label>Name</label><br>
      <autocomplete
        url="/taxon_names/autocomplete"
        label="label_html"
        min="3"
        eventSend="parentSelected"
        display="label"
        param="term">
      </autocomplete>
    </div>
  </form>
</template>

<script>
  const autocomplete = require('../../../components/autocomplete.vue');
  export default {
    components: {
      autocomplete
    }
  }
</script>