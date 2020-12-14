<template>
  <div class="vue-table-container">
    <h3 class="title-section">Recent</h3>
    <table class="vue-table word-keep-all">
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
            <div>
              <citations-count :source-id="item.id"/>
            </div>
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
              :project-source-id="item.project_source_id"
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
import RadialAnnotator from 'components/radials/annotator/annotator'
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
  data () {
    return {
      sources: []
    }
  },
  mounted () {
    GetRecentSources().then(response => {
      this.sources = response.body
    })
  }
}
</script>
