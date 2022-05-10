<template>
  <tr>
    <td>
      <a
        :href="`${routeNames.BrowseOtu}?otu_id=${otu.id}`"
        v-html="otu.object_tag"/>
    </td>
    <td>
      <div class="horizontal-right-content">
        <radial-annotator :global-id="otu.global_id" />
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          :redirect="false"
        />
        <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          redirect
        />
      </div>
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
