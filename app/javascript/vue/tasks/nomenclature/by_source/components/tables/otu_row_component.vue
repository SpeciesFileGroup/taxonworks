<template>
  <tr>
    <td v-html="otu.object_tag"/>
    <td>
      <radial-annotator :global-id="otu.global_id" />
    </td>
    <td>
      <otu-radial
          :taxon-id="otu.global_id"
          :otu="otu"
          :redirect="false"/>
    </td>
  </tr>
</template>
<script>
  import RadialAnnotator from 'components/annotator/annotator'
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
    data () {
      return {
        pages: undefined,
        autoSave: undefined,
        time: 3000
      }
    },
    methods: {
      changePage() {
        let that = this
        if(this.autoSave) {
          clearTimeout(this.autoSave)
        }
        this.autoSave = setTimeout(() => {
          that.$http.post('/otu.json', { otu: this.otu })
        }, this.time)
      }
    }
  }
</script>