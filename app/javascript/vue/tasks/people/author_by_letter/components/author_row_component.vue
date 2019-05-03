<template>
  <tr v-if="author">
    <td class="author-column">
      <a
        v-html="author.cached"
        :href="`/people/${this.author.id}`"/>
    </td>
    <td>
      <button
        v-if="author.roles[0]"
        class="button normal-input button-default"
        @click="showSources">
        Sources
      </button>
    </td>
    <td> {{ author.id }} </td>
    <td>
      <a
        target="blank"
        :href="`/tasks/uniquify_people/index?last_name=${this.author.last_name}`">
        Uniquify
      </a>
    </td>
    <td>
      <pin
        v-if="author.id"
        :object-id="author.id"
        :pluralize="false"
        type="Person"/>
    </td>
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
        default: () => { return {} }
      },
    },
    methods: {
      showSources(id) {
        this.$emit("sources", id);
      },
      showAuthor() {
        window.open('/people/' + this.author.id, '_blank');
      }
    }
  }
</script>
<style scoped>
  .author-column {
    min-width: 200px;
  }
</style>
