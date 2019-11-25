<template>
  <div class="panel header-bar separate-bottom">
    <div class="container content">
      <ul class="breadcrumb_list">
          <li
            v-for="key in Object.keys(navigation.parents).reverse()"
            :key="key"
            class="breadcrumb_item">
            <a
              v-if="navigation.parents[key].length === 1"
              :href="`/tasks/otus/browse/${navigation.parents[key][0].id}`">
              {{key}}
            </a>
            <div
              v-else
              class="dropdown-otu">
              <span>{{key}}</span>
              <ul class="panel dropdown no_bullets">
                <li v-for="otu in navigation.parents[key]"
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
        <radial-annotator
          :global-id="otu.global_id"
          type="annotations"/>
      </div>
      <ul class="context-menu no_bullets">
        <li v-for="item in menu">
          <a>{{item}}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'
import { GetBreadCrumbNavigation } from '../request/resources'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      menu: ['Classification', 'Links', 'Distribution', 'Classification', 'Citations', 'Gallery', 'Specimen records', 'Type information'],
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