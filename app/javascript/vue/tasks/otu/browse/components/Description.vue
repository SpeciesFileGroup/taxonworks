<template>
  <section-panel
    :status="status"
    :title="title">
    <div>
      {{ generatedDescription }}
    </div>
  </section-panel>
</template>

<script>
import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import ajaxCall from 'helpers/ajaxCall'

export default {
  mixins: [extendSection],

  components: { SectionPanel },

  props: {
    otu: {
      type: Object,
      required: true
    }
  },

  data: () => ({
    generatedDescription: ''
  }),

  watch: {
    otu: {
      handler (newVal) {
        if (newVal?.id) {
          this.loadDescription()
        }
      },
      immediate: true
    }
  },

  mounted () {

  },

  methods: {
    loadDescription () {
      ajaxCall('get', '/tasks/observation_matrices/description_from_observation_matrix/description', {
        params: {
          otu_id: this.otu.id,
          include_descendants: true
        }
      }).then(({ body }) => {
        this.generatedDescription = body.generated_description
      })
    }
  }

}
</script>
