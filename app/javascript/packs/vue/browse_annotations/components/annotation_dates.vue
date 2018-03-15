<template>
    <div>
        <input
                name="annotation-dates"
                type="date"
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
    watch: {
      value(newVal) {
        this.getResult(newVal)
      }
    },
    data: function () {
      return {
        annotaton_dates: {
          start: undefined,
          end: undefined
        }
      }
    },
    // mounted: function () {
    //   this.$http.get('/tasks/browse_annotations/get_type_list').then(response => {
    //     console.log(response); // this is necessary to show traffic?
    //     this.list = response.body;
    //   })
    // },
    methods: {
      selectDate(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/set_dates', {annotationDates: newVal}).then(response => {
          // console.log(response); // this is necessary to show traffic?
          this.$emit('annotation_dates_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>