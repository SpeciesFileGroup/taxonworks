<template>
    <div class="flexbox">
        <div class="annotation_type">
            <annotation-types v-model="filter.annotation_type" @annotation_type_selected="filter.common = $event"/>
            <span>Selected: {{ filter.annotation_type }}</span>
        </div>
        <div class="annotation_for">
            <annotation-for v-model="filter.for_selected" @for_selected="filter.common = $event"
                            @result="filter.result = $event"/>
            <span>Selected: {{ filter.for_selected }}</span>
        </div>
        <div class="annotation_on">
            <annotation-on v-model="filter.model" @model_selected="filter.common = $event"
                           @result="filter.result = $event"/>
            <span>Selected: {{ filter.model }}</span>
        </div>
        <div class="annotation_by">
            <!--some text will show now no more -->
        </div>
        <div class="annotation_dates">
            <annotation-dates v-model="filter.annotation_dates" @annotation_dates_selected="filter.common = $event"/>
        </div>
        <div class="annotation_logic">

        </div>
        <!--<span v-for="whatever in filter.result">{{ whatever }}</span>-->
        <!--<span v-if="filter.common">{{ filter.common }}</span>-->
        <span>{{ filter.common }}</span>
        <button
                @click="processCall"
                type="submit">Process
        </button>
    </div>
</template>
<script>

  import AnnotationTypes from './components/annotation_types'
  import AnnotationOn from './components/annotation_on'
  import AnnotationFor from './components/annotation_for'
  import AnnotationDates from './components/annotation_dates'

  export default {
    components: {
      AnnotationTypes,
      AnnotationDates,
      AnnotationOn,
      AnnotationFor
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