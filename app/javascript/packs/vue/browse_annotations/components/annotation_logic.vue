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
    methods: {
      selectLogic(type) {
        this.$emit('input', type.valueOf())
      }
    }
  }
</script>