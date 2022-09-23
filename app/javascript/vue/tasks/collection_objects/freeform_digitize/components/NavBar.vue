<template>
  <nav-bar>
    <div class="flex-separate full_width">
      <div class="middle">
        <span
          v-if="sledImage.id"
          v-html="sledImage.object_tag"/>
        <span v-else>New record</span>
        <template v-if="sledImage.id">
          <radial-annotator :global-id="sledImage.global_id"/>
        </template>
      </div>
      <div class="horizontal-right-content">
        <ul class="context-menu">
          <li>
            <a
              v-if="navigation.previous"
              :href="`/tasks/collection_objects/grid_digitize/index?sled_image_id=${navigation.previous}`">
              Previous
            </a>
            <a
              class="disabled" 
              v-else>Previous
            </a>
          </li>
          <li>
            <a
              v-if="navigation.next"
              :href="`/tasks/collection_objects/grid_digitize/index?sled_image_id=${navigation.next}`">
              Next
            </a>
            <a
              class="disabled" 
              v-else>Next
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav-bar>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { NavigationSled } from '../request/resource'
import RadialAnnotator from 'components/radials/annotator/annotator'
import NavBar from 'components/layout/NavBar'

export default {
  components: {
    NavBar,
    RadialAnnotator
  },

  computed: {
    sledImage () {
      return this.$store.getters[GetterNames.GetSledImage]
    },
    navigation: {
      get () {
        return this.$store.getters[GetterNames.GetNavigation]
      },
      set (value) {
        this.$store.commit(MutationNames.SetNavigation, value)
      }
    }
  },

  watch: {
    sledImage: {
      handler (newVal, oldVal) {
        if (newVal.id && oldVal.id != newVal.id) {
          NavigationSled(this.sledImage.global_id).then(response => {
            this.navigation.next = response.headers['navigation-next'] ? response.headers['navigation-next'][0] : undefined
            this.navigation.previous = response.headers['navigation-previous'] ? response.headers['navigation-previous'][0] : undefined
          })
        }
      }
    }
  }
}
</script>
