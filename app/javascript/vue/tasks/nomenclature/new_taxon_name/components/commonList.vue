<template>
  <div class="flex-wrap-row">
    <ul class="flex-wrap-column no_bullets">
      <template v-for="item in objectLists">
        <li
          class="status-item"
          v-if="!filter || !filterAlreadyPicked(listCreated, item.base_class)">
          <label>
            <input
              type="radio"
              name="status-item"
              @click="$emit('addEntry', item)"
              :value="item.base_class">
            <span>{{ item[display] }}</span>
          </label>
        </li>
      </template>
    </ul>
  </div>
</template>
<script>
export default {
  props: {
    objectLists: {
      type: Array,
      default: () => []
    },

    listCreated: {
      type: Array,
      required: true
    },

    display: {
      type: String,
      required: true
    },

    filter: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    filterAlreadyPicked (list, type) {
      return list.find(item => item.base_class === type)
    }
  }
}
</script>
