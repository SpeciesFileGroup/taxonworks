<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in roleTypes"
          :key=label >
        <input
            type="checkbox"
            @click="selectType(key)">
          {{ roleTypes[key] }}
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
    mounted: function() {
      this.$http.get('/people/role_types.json').then(response => {
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
