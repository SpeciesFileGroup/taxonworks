<template>
  <tr v-if="source">
    <td>
      <a
        v-html="source.cached"
        @click="showSource"/>
    </td>
    <td class="horizontal-left-content">
      <radial-object :global-id="source.global_id"/>
      <pin
        v-if="source.id"
        :object-id="source.id"
        :type="source.type"/>
    </td>
    <td>
      <add-to-project
        :id="source.id"
        :in_project="source.source_in_project"
        :project-source-id="source.project_source_id"/>
    </td>
  </tr>
</template>

<script>

  import Pin from 'components/ui/Pinboard/VPin.vue'
  import AddToProject from 'components/addToProjectSource'
  import RadialObject from 'components/radials/navigation/radial'

  export default {
    components: {
      RadialObject,
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