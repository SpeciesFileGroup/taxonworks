<template>
  <div class="vue-table-container">
    <h3 class="title-section">Recent</h3>
    <table class="vue-table">
      <thead>
        <tr>
          <th>Source</th>
          <th>Year</th>
          <th>Citations</th>
          <th>Documents</th>
          <th>Tags</th>
          <th>Annotate</th>
          <th>Pin</th>
          <th>In project</th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in sources"
          :key="item.id"
          class="list-complete-item">
          <td>
            <a
              :href="`/tasks/sources/new_source?source_id=${item.id}`"
              v-html="item.object_tag"/>
          </td>
          <td> {{ item.year }} </td>
          <td>
            <citations-count :source-id="item.id"/>
          </td>
          <td>
            <documents-component :source-id="item.id"/>
          </td>
          <td>
            <tags-component :source-id="item.id"/>
          </td>
          <td>
            <radial-annotator
              :global-id="item.global_id"/>
          </td>
          <td>
            <pin-component
              :object-id="item.id"
              type="Source"
            />
          </td>
          <td>
            <add-to-project-source
              :project_source_id="item.project_source_id"
              :id="item.id"/>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>

<script>

import { GetRecentSources } from '../request/resources.js'
import PinComponent from 'components/pin.vue'
import RadialAnnotator from 'components/annotator/annotator'
import AddToProjectSource from 'components/addToProjectSource.vue'
import CitationsCount from './citationsCount'
import DocumentsComponent from './documents'
import TagsComponent from './tags'

export default {
  components: {
    TagsComponent,
    RadialAnnotator,
    PinComponent,
    AddToProjectSource,
    CitationsCount,
    DocumentsComponent
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      sources: []
    }
  },
  mounted() {
    GetRecentSources().then(response => {
      this.sources = response.body
    })
  },
  methods: {
    editSource(source) {
      window.open(`/sources/${source.id}/edit`,'blank')
    }
  }
}
</script>

<style lang="scss" scoped>
  .vue-table-container {
    overflow-y: scroll;
    padding: 0px;
    position: relative;
  }

  .vue-table {
    width: 100%;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
    }
    tr {
      cursor: default;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
</style>
