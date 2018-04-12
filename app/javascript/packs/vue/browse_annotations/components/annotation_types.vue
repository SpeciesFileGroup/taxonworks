<template>
  <div>
    <ul>
      <li v-for="(label, key) in list" :key="key">
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
        used_on: {},
        result: undefined
      }
    },
    mounted: function () {
      // this.$http.get('/annotations/types').then(response => {
      this.$http.get('/annotations/types').then(response => {
        let listTypes = {};
        let onList = {};
        let rbTypes = response.body.types;
        Object.keys(rbTypes).forEach(function (key) {
          listTypes[rbTypes[key]["klass"]] = rbTypes[key]["label"];
          onList[rbTypes[key]["klass"]] = rbTypes[key]["used_on"];
          }
        );
        this.used_on = onList;
        this.list = listTypes;
      }
      )
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