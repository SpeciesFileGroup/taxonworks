<template>
    <div class="flexbox">
        <ul>
            <li v-for="(label, key) in list">
                <label @click="selectLogic(key)">
                    <input
                            :checked="value === key"
                            name="annotation-logic"
                            type="radio"
                            :value="key">
                    <span
                            class="new-combination-rank-list-taxon-name"
                            v-html="label"/>
                </label>
            </li>
        </ul>
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
        annotation_logic: {
          andOr: undefined
        },
        result: undefined,
        list: {
          and: 'And',
          or: 'Or'
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
      selectLogic(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/set_logic', {annotationLogic: newVal}).then(response => {
          // console.log(response); // this is necessary to show traffic?
          this.$emit('annotation_logic_selected', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>