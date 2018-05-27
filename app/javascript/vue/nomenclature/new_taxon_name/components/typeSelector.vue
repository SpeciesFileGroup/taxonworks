<template>
  <form class="content" v-if>
    <h3>Type</h3>
    <div class="field">
      <label>Name</label><br>
      <autocomplete
        url="/taxon_names/autocomplete"
        label="label_html"
        min="3"
        event-send="parentSelected"
        display="label"
        param="term"/>
    </div>
  </form>
</template>

<script>
const autocomplete = require('../../../components/autocomplete.vue').default
export default {
  components: {
    autocomplete
  }
}
</script>
