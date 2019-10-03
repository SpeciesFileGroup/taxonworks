<template>
  <div>
    <div v-if="navList">
      <h3>Current</h3>
        <h3>{{ navList.current_otu.object_label }}</h3>
      <h4>Parent</h4>
      <ul class="no_bullets">
        <li
          class="flex-separate middle"
          v-for="item in navList.parent_otus"
          :key="item.id">
          <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          <div class="horizontal-left-content">
            <radial-annotator :globalId="item.global_id"/>
            <radial-object :globalId="item.global_id"/>
          </div>
        </li>
      </ul>
      <h4>Previous</h4>
      <ul class="no_bullets">
        <li 
          class="flex-separate middle"
          v-for="item in navList.previous_otus"
          :key="item.id">
          <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          <div class="horizontal-left-content">
            <radial-annotator :globalId="item.global_id"/>
            <radial-object :globalId="item.global_id"/>
          </div>
        </li>
      </ul>
      <h4>Next</h4>
      <ul class="no_bullets">
        <li
          class="flex-separate middle"
          v-for="item in navList.next_otus"
          :key="item.id">
          <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          <div class="horizontal-left-content">
            <radial-annotator :globalId="item.global_id"/>
            <radial-object :globalId="item.global_id"/>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetNavigationOtu } from '../request/resources'
import RadialAnnotator from 'components/annotator/annotator'
import RadialObject from 'components/radial_object/radialObject'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },
  props: {
    otuId: {
      type: [String, Number],
      default: undefined
    }
  },
  data () {
    return {
      navList: undefined
    }
  },
  watch: {
    otuId(newVal) {
      if(newVal) {
        this.loadNav(newVal)
      }
      else {
        this.navList = []
      }
    }
  },
  methods: {
    loadNav(id) {
      GetNavigationOtu(id).then(response => {
        this.navList = response.body
      })
    }
  }
}
</script>

<style>

</style>