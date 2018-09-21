<template>
  <tr v-if="author">
    <td v-html="author.cached"/>
    <td v-if="author.roles[0]"
        v-html="author.roles[0].role_object_tag"/>
    <td v-else
        v-html=" "/>
    <td><span class="button circle-button btn-delete" @click="removeMe()"/></td>
  </tr>
</template>

<script>

  import RadialAnnotator from '../../../../components/annotator/annotator'
  import OtuRadial from '../../../../components/otu/otu'

  export default {
    components: {
      RadialAnnotator,
      OtuRadial
    },
    props: {
      author: {
        type: Object,
        default: {}
      },
    },
    data() {
      return {
        pages: undefined,
        autoSave: undefined,
        time: 3000
      }
    },
    methods: {
      changePage() {
        let that = this;
        if (this.autoSave) {
          clearTimeout(this.autoSave)
        }
        this.autoSave = setTimeout(() => {
          that.$http.patch('/citations/' + this.citation.id + '.json', {citation: this.citation}).then(response => {
            TW.workbench.alert.create('Citation was successfully updated.', 'notice')
          })
        }, this.time)
      },
      removeMe() {
        this.$emit("delete", this.author)
      }
    }
  }
</script>
<style lang="scss" module>
  .pages {
    width: 140px;
  }
</style>