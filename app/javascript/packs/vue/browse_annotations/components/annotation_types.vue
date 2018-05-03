<template>
  <div>
    <ul>
      <li
        v-for="(item, key) in typesList"
        :key="key">
        <label @click="selectType(key)">
          <input
            :checked="value.type === key"
            name="annotation-type"
            type="radio"
            :value="key">
          <span
            class="new-combination-rank-list-taxon-name"
            v-html="item.label"/>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: Object,
        required: true
      }
    },
    watch: {
      value: {
        handler(newVal) {
          this.getResult(newVal)
          // this.selectType(newVal)
        },
        deep: true
      }
    },
    data: function () {
      return {
        typesList: undefined,
        result: undefined,
          selected: {}
      }
    },
    mounted: function () {
      this.$http.get('/annotations/types').then(response => {
        this.typesList = response.body.types
      })
    },
    methods: {
      selectType(type) {
         this.selected = {
          type: type,
          used_on: this.typesList[type].used_on,
          select_options_url: this.typesList[type].select_options_url,
          all_select_option_url: this.typesList[type].all_select_option_url
        };
        this.$emit('input', this.selected);
        this.$emit('annotation_type_selected', this.typesList[type]);
      }
      ,
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/get_type', { annotationType: newVal.type }).then(response => {
          console.log(response); // this is necessary to show traffic?
          this.$emit('annotation_type_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>