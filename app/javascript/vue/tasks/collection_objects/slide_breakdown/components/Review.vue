<template>
  <div class="panel content">
    <h2>Existing data</h2>
    <table>
      <thead>
        <tr>
          <th>Identifier</th>
          <th>Total</th>
          <th>Radial annotator</th>
          <th>Edit</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in list">
          <td>{{ item.object_tag }}</td>
          <td>{{ item.total }}</td>
          <td>
            <radial-annotator :global-id="item.global_id"/>
          </td>
          <td>
            <span class="button circle-button btn-edit"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    }
  }
}
</script>
