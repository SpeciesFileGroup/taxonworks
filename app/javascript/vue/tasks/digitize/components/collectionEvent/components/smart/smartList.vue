<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.id">
        <label @click="getCollectingEvent(item.id)">
          <input
            :checked="collectingEvent.id == item.id"
            type="radio"
            name="ce-smart">
          {{ item.object_tag }}
        </label>

      </li>
    </ul>
  </div>
</template>

<script>

  import { GetCollectionEvent } from '../../../../request/resources.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'
  import { ActionNames } from '../../../../store/actions/actions.js'
  import { GetterNames } from '../../../../store/getters/getters.js'

  import makeCollectingEvent from '../../../../const/collectingEvent.js'

  export default {
    props: {
      list: {
        type: Array,
        required: true
      }
    },
    computed: {
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      }
    },
    methods: {
      getCollectingEvent(id) {
        GetCollectionEvent(id).then(response => {
          this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response))
          this.$store.dispatch(ActionNames.GetLabels, id)
        })
      }
    }
  }
</script>

<style>

</style>
