<template>
    <div class="flexbox">
        <div class="annotation_type">
            <annotation-types v-model="filter.annotation_type" @annotation_type_selected="filter.common = $event"/>
            <span>Selected: {{ filter.annotation_type }}</span>
        </div>
        <div class="annotation_on">

        </div>
        <div class="annotation_for">
            <models v-model="filter.model" @model_selected="filter.common = $event"/>
            <span>Selected: {{ filter.model }}</span>
        </div>
        <div class="annotation_by">
            <!--some text will show now no more -->
        </div>
        <div class="annotation_dates">

        </div>
        <div class="annotation_logic">

        </div>
        <!--<annotation-types @annotation_type_selected="filter.common = $event"/>-->
        <!--<annotation-types @model_selected="filter.common = $event"/>-->
        <span v-for="json in filter.result">{{ json }}</span>
        <span v-if="filter.common">{{ filter.common }}</span>
        <button
                @click="processCall"
                type="submit">Process
        </button>
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
          model: undefined,
          common: undefined,
          result: undefined
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