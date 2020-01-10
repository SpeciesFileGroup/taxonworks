<template>
  <fieldset>
    <legend>Taxon determination</legend>
    <span>Otu</span>
    <smart-selector
    class="margin-medium-bottom"
      model="otus"
      target="TaxonDetermination"
    />
    <span>Determiner</span>
    <smart-selector
      model="people"
      target="Determiner"
      :autocomplete="false">
      <role-picker
        class="margin-medium-top"
        roleType="Determiner"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import RolePicker from 'components/role_picker'


export default {
  components: {
    SmartSelector,
    RolePicker
  }
}
</script>

<style>

</style>