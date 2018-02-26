<template>
  <div>
    <annotation-types @select="testResult = $event"/>
    <span>Selected: {{ testResult }}</span>
  </div>
    <div>
        <models @select="testResult = $event"/>
        <span>Selected: {{ testResult }}</span>
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