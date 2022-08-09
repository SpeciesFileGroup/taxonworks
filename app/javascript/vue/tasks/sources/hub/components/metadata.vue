<template>
  <div>
    <h3 class="title-section">Metadata</h3>
    <div>
      <div class="horizontal-left-content">
        <div class="panel content separate-right">
          <h3><b>Source</b></h3>
          <ul
            v-if="source"
            class="no_bullets">
            <li>Created this week: {{ source.created_this_week }}</li>
            <li>Updated this week: {{ source.updated_this_week }}</li>
            <li>Created by user: {{ source.created_by_user }}</li>
            <li>Created by others: {{ source.created_by_others }}</li>
          </ul>
        </div>
        <div class="panel content">
          <h3><b>Project source</b></h3>
          <ul 
            v-if="source"
            class="no_bullets">
            <li>Created this week: {{ projectSource.created_this_week }}</li>
            <li>Updated this week: {{ projectSource.updated_this_week }}</li>
            <li>Created by user: {{ projectSource.created_by_user }}</li>
            <li>Created by others: {{ projectSource.created_by_others }}</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import {
  GetMetadataSource,
  GetMetadataProjectSource
} from '../request/resources.js'

export default {
  data () {
    return {
      source: undefined,
      projectSource: undefined
    }
  },

  mounted () {
    GetMetadataSource().then(response => {
      this.source = response.body
    })

    GetMetadataProjectSource().then(response => {
      this.projectSource = response.body
    })
  }
}
</script>
