<template>
  <div
    v-if="list.length"
    class="full_width overflow-scroll">
    <table class="full_width">
      <thead>
        <tr>
          <th>
            <tag-all :ids="ids"/>
          </th>
          <th
            class="capitalize"
            v-for="item in sort"
            @click="sortTable(item)">
            {{item}}
          </th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          :class="{ even: index % 2 }"
          v-for="(item, index) in list"
          :key="item.id">
          <td>
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox">
          </td>
          <td>
            <span>{{ item.id }}</span>
          </td>
          <td>
            <span v-html="item.cached"/>
          </td>
          <td>
            <span>{{ item.year }}</span>
          </td>
          <td>
            <span>{{ item.type }}</span>
          </td>
          <td>
            <div class="flex-wrap-row">
              <pdf-button
                v-for="pdf in item.documents"
                :pdf="pdf"/>
            </div>
          </td>
          <td>
            <div class="horizontal-left-content">
              <radial-annotator :global-id="item.global_id"/>
              <radial-navigation :global-id="item.global_id"/>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <span
      v-if="list.length"
      class="horizontal-left-content">{{ list.length }} records.
    </span>
  </div>
</template>

<script>

import RadialNavigation from 'components/radials/navigation/radial'
import RadialAnnotator from 'components/radials/annotator/annotator'
import TagAll from 'tasks/collection_objects/filter/components/tagAll'
import PdfButton from 'components/pdfButton'

export default {
  components: {
    RadialNavigation,
    RadialAnnotator,
    PdfButton,
    TagAll
  },
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    },
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    ids: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      ascending: false,
      sort: ['id', 'cached', 'year', 'type', 'documents']
    }
  },
  methods: {
    sortTable (sortProperty) {
      let that = this
      function compare (a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (that.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (that.ascending ? 1 : -1)
        return 0
      }
      this.list.sort(compare)
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
