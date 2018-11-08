<template>
  <tr v-if="author">
    <td>
      <a
        v-html="author.cached"
        target="blank"
        :href="`/people/${this.author.id}`"/>
    </td>
    <td> {{ author.id }} </td>
    <td>
      <button
        v-if="author.roles[0]"
        class="button normal-input button-default"
        @click="showSources">
        Sources
      </button>
    </td>
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
        type="People"/>
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
