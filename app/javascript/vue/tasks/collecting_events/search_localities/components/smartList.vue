<template>
  <div>
    <h3 v-if="!list.length">
      No collecting events on your {{ view }} list
    </h3>
    <ul class="no_bullets">
      <template v-for="item in list">
        <li
          v-if="!cesIdSelected.includes(item.id)"
          :key="item.id">
          <label>
            <input
              type="radio"
              :value="item.id"
              @click="$emit('selected', [item])">
            <span v-html="item.object_tag" />
          </label>
        </li>
      </template>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    },
    listSelected: {
      type: Array,
      default: () => { return [] }
    },
    view: {
      type: String,
      default: ''
    }
  },
  computed: {
    cesIdSelected() {
      return this.listSelected.map(ce => { return ce.id})
    }
  }
}
</script>
