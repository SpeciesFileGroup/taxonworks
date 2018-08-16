<template>
  <table>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
        class="contextMenuCells">
        <td v-html="item.object_tag"/>
        <td>
          <radial-annotator :global-id="item.global_id"/>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import RadialAnnotator from '../../../components/annotator/annotator'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>

<style>

</style>
