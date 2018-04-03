<template>
  <div>
    <ul>
      <li v-for="(label, key) in list">
        <label @click="selectType(key)">
          <input
            :checked="value === key"
            name="annotation-type"
            type="radio"
            :value="key">
          <span
            class="new-combination-rank-list-taxon-name"
            v-html="label"/>
        </label>
      </li>
    </ul>
    <!--<span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>-->
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
        list: {
        },
        result: undefined
      }
    },
    mounted: function () {
      this.$http.get('/tasks/browse_annotations/get_type_list').then(response => {
        // console.log(response); // this is necessary to show traffic?
        this.list = response.body;
      })
    },
    methods: {
      selectType(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/get_type', {annotationType: newVal}).then(response => {
          // console.log(response); // this is necessary to show traffic?
          this.$emit('annotation_type_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>