<template>
  <tr v-if="author">
    <td v-html="author.cached"/>
    <td v-if="author.roles[0]"
        v-html="'list sources for: ' + author.id" @click="showSources"/>
    <td v-else
        v-html=" "/>
    <td v-html="'Show: ' + author.id" @click="showAuthor"/>
    <td v-html="'Uniquify: ' + author.id" @click="uniquify"/>
    <td>
      <pin v-if="author.id" :object-id="author.id" :type="author.type"/>
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
      showSources(id) {
        this.$emit("sources", id);
      },
      showAuthor() {
        window.open('/people/' + this.author.id, '_blank');
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