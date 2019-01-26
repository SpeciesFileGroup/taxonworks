<template>
  <table>
    <thead>
      <tr>
        <th>Source</th>
        <th>Otu</th>
        <th>Geographic area</th>
        <th>Trash</th>
        <th>Radial annotator</th>
        <th>Source/Otu clone</th>
        <th>Source/Geo clone</th>
        <th>OTU/Geo clone</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id">
        <td v-html="item.citations[0].citation_source_body"/>
        <td v-html="item.otu.object_tag"/>
        <td v-html="item.geographic_area.name"/>
        <td>
          <span 
            class="button circle-button btn-delete"
            @click="removeItem(item)"/>
        </td>
        <td>
          <radial-annotator
            type="annotations"
            :global-id="item.global_id"
          />
        </td>
      </tr>
    </tbody>
  </table>
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
  },
  methods: {
    removeItem(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('remove', item)
      }
    }
  }

}
</script>
