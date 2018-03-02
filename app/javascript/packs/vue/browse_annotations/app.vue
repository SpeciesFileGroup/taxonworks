<template>
    <div class="flexbox">
        <div class="annotation_type">
            <annotation-types @select="annotation_type = $event"/>
            <span>Selected: {{ annotation_type }}</span>
        </div>
        <div class="annotation_on">

        </div>
        <div class="annotation_for">
            <models @select="model = $event"/>
            <span>Selected: {{ model }}</span>
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
        annotation_type: undefined,
        model: undefined
      }
    },
  }
</script>