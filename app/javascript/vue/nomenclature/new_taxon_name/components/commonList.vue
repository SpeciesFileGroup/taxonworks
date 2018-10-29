<template>
  <div class="flex-wrap-row">
    <ul class="flex-wrap-column no_bullets">
      <li
        class="status-item"
        v-for="item in objectLists"
        v-if="!filter || filterAlreadyPicked(listCreated, item.base_class) == undefined">
        <label>
          <input
            type="radio"
            name="status-item"
            @click="$emit('addEntry', item)"
            :value="item.base_class">
          <span>{{ item[display] }}</span>
        </label>
      </li>
    </ul>
  </div>
</template>
<script>
export default {
  props: {
    objectLists: {
      required: true
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
    filterAlreadyPicked: function (list, type) {
      return list.find(function (item) {
        return (item.base_class == type)
      })
    }
  }
}
</script>
