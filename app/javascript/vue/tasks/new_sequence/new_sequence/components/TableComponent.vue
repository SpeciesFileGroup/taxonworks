<template>
  <div>
    <h2>Sequence being annotated</h2>
    <table>
      <thead>
        <tr>
          <th>Sequence</th>
          <th>Name</th>
          <th>Type</th>
          <th>Target</th>
          <th>Radial annotator</th>
          <th>Destroy</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td>
            {{ item.sequence }}
          </td>
          <td>
            {{ item.name }}
          </td>
          <td>
            {{ item.type }}
          </td>
          <td>
            {{ item.target }}
          </td>
          <td>
            <radial-annotator
              type="annotations"
              :global-id="item.global_id"/>
          </td>
          <td>
            <span class="button circle-button btn-delete"/>
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
      required: true
    }
  }
}
</script>
