<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in roleTypes"
        :key="key">
        <input
          type="checkbox"
          @click="selectType(key)">
        {{ roleTypes[key] }}
      </li>
    </ul>
  </div>
</template>

<script>
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    props: {
      value: {
        type: Object,
        required: true
      }
    },
    mounted: function() {
      AjaxCall('get', '/people/role_types.json').then(response => {
      this.roleTypes = response.body;
      this.loading = false;
    })
  },
    data() {
      return {
        roleTypes: {},
        selectedList: {}
      };
    },
    methods: {
      selectType(type) {   // clicked one of the types provided from role_types
        if (this.selectedList.hasOwnProperty(type)) {
          this.$delete(this.selectedList, type)
        }
        else {
          this.$set(this.selectedList, type, this.roleTypes[type]);
        }
        this.$emit('input', this.selectedList);
      }
    }
  };
</script>
