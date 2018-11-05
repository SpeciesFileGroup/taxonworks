<template>
  <div>
    <ul>
      <li
        v-for="item in list"
        v-html="item.object_tag"/>
    </ul>
  </div>
</template>

<script>

  import { GetCollectionEvent } from '../../../../request/resources.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'

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
          this.$store.commit(MutationNames.SetCollectionEvent, response)
        })
      }
    }
  }
</script>

<style>

</style>
