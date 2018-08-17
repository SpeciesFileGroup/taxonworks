<template>
  <table>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
        class="contextMenuCells">
        <td v-html="item.object_tag"/>
        <td>
          <div class="horizontal-left-content">
            <radial-annotator :global-id="item.global_id"/>
            <add-to-project :id="item.id"/>
            <pin-component 
              :object-id="item.id"
              :type="item.type"/>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import RadialAnnotator from '../../../components/annotator/annotator'
import AddToProject from '../../../components/addToProjectSource'
import PinComponent from '../../../components/pin'

export default {
  components: {
    RadialAnnotator,
    AddToProject,
    PinComponent
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>
