<template>
  <div
    v-if="list.length"
    class="full_width overflow-scroll">
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr v-for="otu in list">
          <td v-html="otu.object_tag"></td>
          <td class="horizontal-right-content">
            <radial-annotator :global-id="otu.global_id"/>
            <radial-object :global-id="otu.global_id"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/object/radial'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },

    modelValue: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    ids: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      ascending: false
    }
  },

  methods: {
    sortTable (sortProperty) {
      const compare = (a,b) => {
        if (a[sortProperty] < b[sortProperty])
          return (this.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (this.ascending ? 1 : -1)
        return 0
      }
      this.list.data.sort(compare)
      this.ascending = !this.ascending
    }
  }
}
</script>

<style lang="scss" scoped>
  table {
    margin-top: 0px;
  }
  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
  .overflow-scroll {
    overflow: scroll;
  }
</style>
