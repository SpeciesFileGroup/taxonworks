<template>
    <div class="flexbox">
        Start: <input v-model="annotation_dates.start"
                      name="dateStart"
                      type="date"
                      @change="getResult()"
        />
        <br>
        End: <input v-model="annotation_dates.end"
               name="dateEnd"
               type="date"
               @change="getResult()"
        />

        <!--<span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>-->
    </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: Object,
      }
    },
    data: function () {
      return {
        annotation_dates: {
          start: "2011-01-01",
          end: "2015-11-11"
        },
        result: undefined
      }
    },
    methods: {
      getResult() {
        this.$http.post('/tasks/browse_annotations/set_dates', {annotationDates: this.annotation_dates}).then(response => {
          this.$emit('input', response.body.annotationDates);
          this.$emit('annotation_dates_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>