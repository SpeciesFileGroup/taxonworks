<template>
    <ul>
        <li v-for="label, key in list">
            <label @click="selectModel(key)">
                <input
                        name="model"
                        type="radio"
                        :value="key">
                <span
                        class="new-combination-rank-list-taxon-name"
                        v-html="label"/>
            </label>
        </li>
    </ul>
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
        }
      }
    },
    methods: {
      selectModel(type) {
        this.$emit('select', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/set_model', {propertyHere: newVal}).then(response => {
          this.$emit('model_selected', response.body)
        })
      }

    }
  }
</script>