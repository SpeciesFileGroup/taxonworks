<template>
    <div class="flexbox">
        <div class="annotation_type">
            <annotation-types v-model="filter.annotation_type"/>
            <span>Selected: {{ filter.annotation_type }}</span>
        </div>
        <div class="annotation_on">

        </div>
        <div class="annotation_for">
            <models @select="filter.model = $event"/>
            <span>Selected: {{ filter.model }}</span>
        </div>
        <div class="annotation_by">

        </div>
        <div class="annotation_dates">

        </div>
        <div class="annotation_logic">

        </div>
        <annotation_type @annotation_type_selected="theDataNameProperty = $event"/>
        <span v-for="json in result">{{ json }}</span>
        <button
          @click="processCall"
          type="submit">Process</button>
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
        filter: {
          annotation_type: 'confidence',
          model: undefined
        }
      }
    },
    // watch: {
    //   //This will check if any value inside of filter object has change
    //   filter: {
    //     handler() {
    //       this.processCall()
    //     },
    //     deep: true
    //   }
    // },
    methods: {
      processCall() {
        let data = {} // Here would be the structure that you will need to make for the response, but could be directly done on data()
        this.$http.post('/tasks/browse_annotations/process_submit', data).then(response => {
          //Here is the example of how to make a post and get the data from the response
          console.log(response)
        })
      }
    }
  }
</script>