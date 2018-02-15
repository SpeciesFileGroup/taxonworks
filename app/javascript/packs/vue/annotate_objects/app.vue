<template>
  <div>
    <annotation-types @select="testResult = $event"/>
    <span>Selected: {{ testResult }}</span>
  </div>
</template>
<script>

import AnnotationTypes from './annotation_types/annotation_types'

export default {
  components: {
    AnnotationTypes
  },
  data() {
    return {
      testResult: undefined
    }
  },
}
</script>