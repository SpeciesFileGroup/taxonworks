<template>
  <div>
    <template>
      <a
        v-if="pagination['previousPage']"
        class="cursor-pointer"
        @click="sendPage(pagination.previousPage)">Previous
      </a>
      <span v-else>
        Previous
      </span>
    </template>
    <template>
      <a        
        v-if="pagination['nextPage']"
        class="cursor-pointer"
        @click="sendPage(pagination.nextPage)">Next
      </a>
      <span v-else>
        Next
      </span>
    </template>
  </div>
</template>

<script>
export default {
  props: {
    pagination: {
      type: Object,
      required: true
    }
  },
  methods: {
    sendPage(page) {
      this.$emit('nextPage', { page: page })
    }
  }
}
</script>
