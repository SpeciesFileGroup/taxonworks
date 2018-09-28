<template>
  <tr v-if="source">
    <td><a v-html="source.cached" @click="showSource"/></td>
    <td>
      <pin v-if="source.id"
           :object-id="source.id"
           :type="source.type"/>
    </td>
    <td>
      <add-to-project :id="source.id" :in_project="false"/>
    </td>
    <td><span class="button circle-button btn-delete" @click="removeMe()"/></td>
  </tr>
</template>

<script>

  import RadialAnnotator from '../../../../components/annotator/annotator'
  import Pin from '../../../../components/pin'
  import AddToProject from '../../../../components/addToProjectSource'

  export default {
    components: {
      RadialAnnotator,
      Pin,
      AddToProject
    },
    props: {
      source: {
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
      showSources(id) {
        this.$emit("sources", id);
      },
      showSource() {
        window.open('/sources/' + this.source.id, '_blank');
      },
      uniquify() {
        window.open('/tasks/uniquify_people/index?last_name=' + this.author.last_name, '_blank');
      },
      changePage() {
        let that = this;
        if (this.autoSave) {
          clearTimeout(this.autoSave)
        }
        this.autoSave = setTimeout(() => {
          //   that.$http.patch('/citations/' + this.citation.id + '.json', {citation: this.citation}).then(response => {
          //     TW.workbench.alert.create('Citation was successfully updated.', 'notice')
          //   })
        }, this.time)
      },
      removeMe() {
        this.$emit("delete", this.source)
      }
    }
  }
</script>
<style lang="scss" module>
  .pages {
    width: 140px;
  }
</style>