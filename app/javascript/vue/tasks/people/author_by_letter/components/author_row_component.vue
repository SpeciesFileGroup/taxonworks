<template>
  <tr v-if="author">
    <td>
      <a
        v-html="author.cached"
        target="blank"
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
        :type="author.type"/>
    </td>
    <td>
      <span
        class="button circle-button btn-delete"
        @click="removeMe()"/>
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
      },
      removeMe() {
        this.$emit("delete", this.author)
      }
    }
  }
</script>
