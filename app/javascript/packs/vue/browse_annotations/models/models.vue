<template>
    <div>
        <ul>
            <li v-for="label, key in list">
                <label @click="selectModel(key)">
                    <input
                            :checked="value === key"
                            name="model"
                            type="radio"
                            :value="key">
                    <span
                            class="new-combination-rank-list-taxon-name"
                            v-html="label"/>
                </label>
            </li>
        </ul>
        <span v-for="(item, key) in result"> {{ key }} : {{ item }} </span>
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
    data() {
      return {
        list: {
          otu: 'by OTU',
          taxon_name: 'by Taxon Name',
          specimen: 'by Specimen'
        },
        result: undefined
      }
    },
    methods: {
      selectModel(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/set_model', {annotationFor: newVal}).then(response => {
          console.log(response);
          this.$emit('model_selected', response.body);
          this.$emit(result, response.body)
        })
      }
    }
  }
</script>