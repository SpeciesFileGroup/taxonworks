<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.id">
        <label @click="getCollectingEvent(item.id)">
          <input
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

  import makeCollectingEvent from '../../../../const/collectingEvent.js'

  export default {
    props: {
      list: {
        type: Array,
        required: true
      }
    },
    methods: {
      getCollectingEvent(id) {
        GetCollectionEvent(id).then(response => {
          this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response))
        })
      }
    }
  }
</script>

<style>

</style>
