<template>
    <div class="flexbox">
        <input v-model="annotation_dates.start"
               name="dateStart"
               type="date"
               @change="getResult()"
        />
        <input v-model="annotation_dates.end"
               name="dateEnd"
               type="date"
               @change="getResult()"
        />

        <span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>
    </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: String,
      }
    },
    data: function () {
      return {
        annotation_dates: {
          start: undefined,
          end: undefined
        },
        result: undefined
      }
    },
    methods: {
      getResult() {
        this.$http.post('/tasks/browse_annotations/set_dates', {annotationDates: this.annotation_dates}).then(response => {
          this.$emit('annotation_dates_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>