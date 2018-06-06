<template>
  <div>
    <ul class="no_bullets">
      <li
          v-for="(label, key) in roleType"
          :key=label >
        <button
            type="button"
            :class="{ 'button-default': (key != value)}"
            class="button normal-input biocuration-toggle-button"
            @click="selectType(key)">
          {{ label }}
        </button>
      </li>
    </ul>
  </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: String,
        default: ''
      },
      roleType: {
        type: Object,
        required: true
      }
    },
    mounted: function() {
      this.$http.get('/people/role_types.json').then(response => {
      this.typesList = response.body.types
      this.loading = false
    })
  },
    watch: {
      annotationType() {
        this.$emit('input', undefined); // clear the selected annotation_on model button
      }
    },
    data() {
      return {
        list: {},
        result: undefined
      };
    },
    methods: {
      selectType(type) {   // clicked one of the types provided from role_types
        this.$emit("input", type.valueOf());
      }
    }
  };
</script>