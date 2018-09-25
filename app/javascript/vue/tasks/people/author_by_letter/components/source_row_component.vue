<template>
  <tr v-if="source">
    <td v-html="source.cached"/>
    <td v-html="'Show: ' + source.id" @click="showSource"/>
    <td>
      <pin v-if="source.id"
           :object-id="source.id"
           :type="source.type"/>
    </td>
    <td><span class="button circle-button btn-delete" @click="removeMe()"/></td>
  </tr>
</template>

<script>

  import RadialAnnotator from '../../../../components/annotator/annotator'
  import Pin from '../../../../components/pin'

  export default {
    components: {
      RadialAnnotator,
      Pin
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