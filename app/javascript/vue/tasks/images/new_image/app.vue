<template>
  <div id="vue-task-images-new">
    <h1>Task: New images</h1>
    <div class="panel content separate-bottom">
      <depiction-component/>
    </div>
    <div class="separate-top separate-bottom">
      <apply-attributes/>
    </div>
    <div class="separate-top separate-bottom">
      <persons-section/>
    </div>
    <div class="separate-top separate-bottom">
      <depic-some/>
    </div>
  </div>
</template>

<script>

import DepictionComponent from 'components/depictions/depictions'
import ApplyAttributes from './components/applyAttributes'
import PersonsSection from './components/personsSection'
import DepicSome from './components/depicSome'

export default {
  components: {
    DepictionComponent,
    ApplyAttributes,
    PersonsSection,
    DepicSome
  }
}
</script>

<style lang="scss">
  #vue-task-images-new {
    .panel-section {
flex-grow: 1;
  flex-shrink: 1;
  flex-basis: 0;
    }
  }
</style>