<template>
  <div class="flexbox">
    <div class="annotation_type">
      <annotation-types
        v-model="filter.annotation_type" />
    </div>
    <div class="annotation_for">
      <annotation-for
        v-model="filter.selected_for"
        :select-options-url="filter.annotation_type.select_options_url"
        :all-select-option-url="filter.annotation_type.all_select_option_url"
        :on-model="filter.model"
        :annotation-type="filter.annotation_type"
        @selected_for="filter.selected_for = $event"
    </div>
    <div class="annotation_on">
      <annotation-on
        v-model="filter.model"
        :annotation-type="filter.annotation_type"
        @model_selected="filter.selected_on = $event"
        @result="filter.result = $event"/>
    </div>
    <div class="annotation_by">
      <annotation-by
        v-model="filter.selected_by" />
    </div>
    <div class="annotation_dates">
      <annotation-dates 
        v-model="filter.annotation_dates" 
        @annotation_dates_selected="filter.common = $event"/>
    </div>
    <div 
      class="annotation_logic"
      style="alignment: center">
      <annotation-logic
        v-model="filter.annotation_logic"
        @annotation_logic_selected="filter.common = $event"/>
    </div>
    <span>{{ filter.common }}</span>
    <button
      @click="processResult"
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
          selected_type: undefined,
          selected_for: {          },
          selected_on: undefined,
          selected_by: undefined,
          model: undefined,
          common: undefined,
          result: 'initial result'
        }
      }
    },
    // watch: {
    //   //This will check if any value inside of filter object has change
    //   filter: {
    //     handler() {
    //       this.processResult()
    //     },
    //     deep: true
    //   }
    // },
    methods: {
      processResult() {
        console.log('params: ');

        let params = {
          params: { 
            for: Object.values(this.filter.selected_for).map(item => item.id),
            on: [this.filter.model],
            by: Object.values(this.filter.selected_by).map(item => item.id)
          }
        };
        console.log(params);
        this.$http.get(`/${this.filter.annotation_type.type}.json`, params).then(response => {
          console.log(response.body);
        })
      }
    }
  }
</script>