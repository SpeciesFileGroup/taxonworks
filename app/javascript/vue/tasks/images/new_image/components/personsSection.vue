<template>
  <div>
    <div class="flexbox separate-bottom">
      <person-box
        class="separate-right panel-section"
        role-type="AttributionCreator"
        title="Author/Creator"/>
      <person-box
        class="separate-left separate-right panel-section"
        role-type="AttributionEditor"
        title="Editor"/>
      <person-box
        class="separate-left panel-section"
        role-type="AttributionOwner"
        title="Owner"/>
    </div>
    <div class="flexbox">
      <licenses-section class="separate-right panel-section"/>
      <copyright-holder
        class="separate-left"
        role-type="AttributionCopyrightHolder"
        title="Copyright holder"/>
    </div>
  </div>
</template>

<script>

import PersonBox from './personsBox'
import CopyrightHolder from './copyrightHolder'
import LicensesSection from './licensesSection'


export default {
  components: {
    PersonBox,
    LicensesSection,
    CopyrightHolder
  }
}
</script>
