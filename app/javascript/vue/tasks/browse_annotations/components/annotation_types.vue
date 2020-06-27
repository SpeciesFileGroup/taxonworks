<template>
  <div>
    <spinner
      v-if="loading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
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
          <span v-html="item.label"/>
          <template>
            <span class="subtle" v-if="item.total == 0"> (no records)</span>
            <span class="subtle" v-else>{{ item.total }} records</span>
          </template>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

  import Spinner from 'components/spinner.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      Spinner
    },
    props: {
      value: {
        type: Object,
        required: true
      }
    },
    data: function () {
      return {
        typesList: {},
        selected: {},
        loading: true
      }
    },
    mounted: function () {
      AjaxCall('get', '/annotations/types').then(response => {
        this.typesList = response.body.types
        this.loading = false
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