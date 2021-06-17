<template>
  <tr>
    <td>
      <a
        :href="`${routeNames.BrowseOtu}?otu_id=${otu.id}`"
        v-html="otu.object_tag"/>
    </td>
    <td>
      <radial-annotator :global-id="otu.global_id" />
    </td>
    <td>
      <otu-radial
        :taxon-id="otu.global_id"
        :otu="otu"
        :redirect="false"/>
    </td>
    <td>
      <otu-radial
        :taxon-id="otu.global_id"
        :otu="otu"
        redirect/>
    </td>
  </tr>
</template>
<script>

import { RouteNames } from 'routes/routes'
import RadialAnnotator from 'components/radials/annotator/annotator'
import OtuRadial from 'components/otu/otu'

export default {
  components: {
    RadialAnnotator,
    OtuRadial
  },

  props: {
    otu: {
      type: Object,
      required: true
    }
  },

  computed: {
    routeNames: () => RouteNames
  }
}
</script>
