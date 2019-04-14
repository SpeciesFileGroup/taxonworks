<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
          <th>Author</th>
          <th>Year</th>
          <th>Original citation</th>
          <th>Original combination</th>
          <th>Valid?</th>
          <th>Valid children</th>
          <th>Valid parents</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td v-html="item.cached_html"/>
          <td>{{item.verbatim_author}}</td>
          <td>{{ item.year_of_publication }}</td>
          <td></td>
          <td v-html="item.original_combination"></td>
          <td></td>
          <td></td>
          <td></td>
          <td class="options-column">
            <div class="horizontal-left-content">
              <pin-component 
                :object-id="item.id"
                :type="item.base_class"/>
              <radial-object :global-id="item.global_id"/>
              <radial-annotator
                type="annotations"
                :global-id="item.global_id"/>
              <default-tag :global-id="item.global_id"/>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import PinComponent from 'components/pin'
import RadialAnnotator from 'components/annotator/annotator'
import RadialObject from 'components/radial_object/radialObject'
import DefaultTag from 'components/defaultTag'

export default {
  components: {
    PinComponent,
    RadialAnnotator,
    RadialObject,
    DefaultTag
  },
  props: {
    list: {
      type: Array,
      default: () => { return [] }
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
</style>
