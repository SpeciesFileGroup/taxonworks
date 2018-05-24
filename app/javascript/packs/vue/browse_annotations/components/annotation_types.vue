<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="(item, key) in typesList"
        :key="key">
        <label @click="(item.total == 0 ? false : selectType(key))">
          <input
            :checked="value.type === key"
            :disabled="item.total == 0"
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
    data: function () {
      return {
        typesList: {},
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
      }
    }
  }
</script>