<template>
  <div class="flexbox">
    <div class="annotation_type">
      <annotation-types
        v-model="filter.annotation_type"
        @annotation_type_selected="filter.common = $event"/>
      <!--<span>Selected: {{ filter.annotation_type }}</span>-->
    </div>
    <div class="annotation_for">
      <annotation-for
        v-model="filter.for_selected"
        :select-options-url="filter.annotation_type.select_options_url"
        :all-select-option-url="filter.annotation_type.all_select_option_url"
        :on-model="filter.model"
        :annotation-type="filter.annotation_type"
        @for_selected="filter.common = $event"
        @result="filter.result = $event"/>
      <span>Result: {{ filter.result }}</span>
    </div>
    <div class="annotation_on">
      <annotation-on
        v-model="filter.model"
        :used-on="filter.annotation_type.used_on"
        :annotation-type="filter.annotation_type"
        @model_selected="filter.common = $event"
        @result="filter.result = $event"/>
      <!--<span>Selected: {{ filter.model }}</span>-->
    </div>
    <div class="annotation_by">
      <annotation-by
        v-model="filter.member_selected" />
    </div>
    <div class="annotation_dates">
      <annotation-dates 
        v-model="filter.annotation_dates" 
        @annotation_dates_selected="filter.common = $event"/>
      <!--<span>Selected: {{ filter.annotation_dates.start }} - {{ filter.annotation_dates.end }}</span>-->
    </div>
    <div 
      class="annotation_logic"
      style="alignment: center">
      <annotation-logic
        v-model="filter.annotation_logic"
        @annotation_logic_selected="filter.common = $event"/>
    <!--<span>Selected: {{ // filter.annotation_logic.andOr }}</span>-->
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
  import AnnotationLogic from './components/annotation_logic'
  import AnnotationBy from "./components/annotation_by";

  export default {
    components: {
      AnnotationBy,
      AnnotationTypes,
      AnnotationFor,
      AnnotationOn,
      AnnotationDates,
      AnnotationLogic
    },

    data() {
      return {
        filter: {
          annotation_type: {
            type: undefined,
            used_on: undefined,
            select_options_url: undefined,
            all_select_option_url: undefined
          },
          annotation_dates: {
            start: undefined,
            end: undefined
          },
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