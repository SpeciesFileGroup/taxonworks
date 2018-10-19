<template>
  <tr v-if="author">
    <td><a v-html="author.cached" @click="showAuthor"/></td>
    <td v-if="author.roles[0]"
        v-html="'list sources for: ' + author.id" @click="showSources"/>
    <td v-else
        v-html=" "/>
    <td v-html="'Uniquify: ' + author.id" @click="uniquify"/>
    <td>
      <pin v-if="author.id" :object-id="author.id" :type="author.type"/>
    </td>
    <td><span class="button circle-button btn-delete" @click="removeMe()"/></td>
  </tr>
</template>

<script>

  import RadialAnnotator from 'components/annotator/annotator'
  import Pin from 'components/pin'

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
      removeMe() {
        this.$emit("delete", this.author)
      }
    }
  }
</script>
