<template>
  <tr v-if="source">
    <td>
      <a
        v-html="source.cached"
        @click="showSource"/>
    </td>
    <td>
      <pin
        v-if="source.id"
        :object-id="source.id"
        :type="source.type"/>
    </td>
    <td>
      <add-to-project
        :id="source.id"
        :in_project="source.source_in_project"
        :project_source_id="source.project_source_id"/>
    </td>
  </tr>
</template>

<script>

  import RadialAnnotator from 'components/annotator/annotator'
  import Pin from 'components/pin'
  import AddToProject from 'components/addToProjectSource'

  export default {
    components: {
      RadialAnnotator,
      Pin,
      AddToProject
    },
    props: {
      source: {
        type: Object,
        default: () => { return {} }
      },
    },
    methods: {
      showSources(id) {
        this.$emit("sources", id);
      },
      showSource() {
        window.open(`sources/${this.source.id}`, '_blank');
      },
      uniquify() {
        window.open(`/tasks/uniquify_people/index?last_name=${this.author.last_name}`, '_blank');
      }
    }
  }
</script>