<template>
    <div class="flexbox">
        <div class="annotation_type">
            <annotation-types @select="testResult = $event"/>
            <span>Selected: {{ testResult }}</span>
        </div>
        <div class="annotation_on">

        </div>
        <div class="annotation_for">
            <models @select="testResult = $event"/>
            <span>Selected: {{ testResult }}</span>
        </div>
        <div class="annotation_by">

        </div>
        <div class="annotation_dates">

        </div>
        <div class="annotation_logic">

        </div>
        <button type="submit">Process</button>
    </div>
</template>
<script>

  import AnnotationTypes from './annotation_types/annotation_types'
  import Models from './models/models'

  export default {
    components: {
      AnnotationTypes,
      Models
    },
    data() {
      return {
        testResult: undefined
      }
    },
  }
</script>