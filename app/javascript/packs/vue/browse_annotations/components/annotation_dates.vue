<template>
    <div class="flexbox">
        <input v-model="annotation_dates.start"
               name="dateStart"
               type="date"
               @change="selectDate()"
        />
        <input v-model="annotation_dates.end"
               name="dateEnd"
               type="date"
               @change="selectDate()"
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
        annotation_dates: {
          start: undefined,
          end: undefined
        },
        result: undefined
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