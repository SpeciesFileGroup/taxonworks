<template>
  <div>
    <div>
      <label>Group</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Formation</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Member</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
      <label>Lithology</label>
      <autocomplete
        url="/url"
        min="2"
        param="term"/>
    </div>
    <div class="horizontal-left-content ma-fields">
      <div class="separate-right">
        <label>Maximum MA</label>
        <input type="text">
      </div>
      <div class="separate-left">
        <label>Minumum MA</label>
        <input type="text">
      </div>
    </div>
  </div>
</template>

<script>

  import Autocomplete from '../../../../../../components/autocomplete.vue'

  export default {
    components: {
      Autocomplete
    }
  }
</script>

<style lang="scss" scoped>
  .ma-fields {
    input {
      width: 60px;
    }
  }
</style>
