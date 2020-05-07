<template>
  <div class="panel separate-bottom">
    <div class="content">
      <ul
        v-if="navigation"
        class="breadcrumb_list">
        <li
          v-for="(item, key) in navigation.parents"
          :key="key"
          class="breadcrumb_item">
          <a
            v-if="item.length === 1"
            :href="`/tasks/otus/browse/${item[0].id}`">
            {{ key }}
          </a>
          <div
            v-else
            class="dropdown-otu">
            <a>{{ key }}</a>
            <ul class="panel dropdown no_bullets">
              <li>Parents</li>
              <li v-for="otu in item"
              :key="otu.id">
                <a :href="`/tasks/otus/browse/${otu.id}`">{{ otu.object_label }}</a>
              </li>
            </ul>
          </div>
        </li>
        <li 
          class="breadcrumb_item current_breadcrumb_position"
          v-html="navigation.current_otu.object_label"/>
      </ul>
      <div class="horizontal-left-content middle">
        <h1
          v-html="otu.object_tag"/>
        <div class="horizontal-left-content">
          <radial-annotator
            :global-id="otu.global_id"
            type="annotations"/>
          <radial-object
            :global-id="otu.global_id"
            type="annotations"/>
          <quick-forms :global-id="otu.global_id"/>
        </div>
      </div>
      <ul class="context-menu no_bullets">
        <li v-for="item in menu">
          <a data-turbolinks="false" :href="`#${item.replace(' ', '-').toLowerCase()}`">{{item}}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial.vue'
import QuickForms from 'components/radials/object/radial.vue'
import { GetBreadCrumbNavigation } from '../request/resources'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    RadialAnnotator,
    RadialObject,
    QuickForms,
    Autocomplete
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      menu: ['Descendants', 'Timeline', 'Images', 'Common names', 'Asserted distributions', 'Content', 'Type specimens', 'Specimen records', 'Biological associations', 'Annotations', 'Collecting events'],
      navigation: undefined
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        GetBreadCrumbNavigation(newVal.id).then(response => {
          this.navigation = response.body
        })
      },
      immediate: true
    }
  },
  methods: {
    loadOtu(event) {
      window.open(`/tasks/otus/browse?otu_id=${event.id}`, '_self')
    }
  }

}
</script>

<style lang="scss" scoped>
  .header-bar {
    margin-left: -15px;
    margin-right: -15px;
  }
  .container {
    margin: 0 auto;
    width:1240px;
  }
  .breadcrumb_list {
    margin-bottom: 32px;
  }

  .dropdown {
    display: none;
    position: absolute;
    padding: 12px;
  }

  .dropdown-otu:hover {
    .dropdown {
      display: block;
    }
  }
</style>