<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in roleTypes"
          :key=label >
        <button
            type="button"
            :class="{ 'button-default': (key != value)}"
            class="button normal-input biocuration-toggle-button"
            @click="selectType(key)">
          {{ key }}
        </button>
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
      },
      // roleTypes: {
      //   type: Object,
      //   required: true
      // }
    },
    mounted: function() {
      this.$http.get('/people/role_types.json').then(response => {
      this.roleTypes = response.body.types
      this.loading = false
    })
  },
    // watch: {
    //   annotationType() {
    //     this.$emit('input', undefined); // clear the selected annotation_on model button
    //   }
    // },
    data() {
      return {
        roleTypes: {},
        selectedList: {}
      };
    },
    methods: {
      selectType(type) {   // clicked one of the types provided from role_types
        if (this.selectedList.hasOwnProperty(item.id)) {
          this.$delete(this.selectedList, item.id)
        }
        else {
          this.$set(this.selectedList, item.id, item);
        }
        this.$emit('input', this.selectedList);
      }
    }
  };
</script>