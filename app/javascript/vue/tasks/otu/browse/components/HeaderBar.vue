<template>
  <div class="panel">
    <div class="content flex-separate middle">
      <span v-html="otu.object_tag"/>
      <ul class="context-menu">
        <li>
          <radial-annotator
            :global-id="otu.global_id"
            type="annotations"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  }
}
</script>
