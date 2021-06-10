<template>
  <table>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
        class="contextMenuCells">
        <td>
          <a 
            :href="`/sources/${item.id}`"
            v-html="item.object_tag"/>
        </td>
        <td>
          <add-to-project :id="item.id"/>
        </td>
        <td>
          <radial-annotator :global-id="item.global_id"/>
        </td>
        <td>
          <pin-component
            :object-id="item.id"
            :type="item.base_class"/>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import RadialAnnotator from 'components/radials/annotator/annotator'
import AddToProject from 'components/addToProjectSource'
import PinComponent from 'components/ui/Pinboard/VPin.vue'

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
