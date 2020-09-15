<template>
  <div class="dwc-table-cell">
    <button
      type="button"
      class="button normal-input button-default"
      v-for="(item, key) in importedObjects"
      :key="key"
      @click="importedCount === 1 ? loadTask(key, item) : openModal()"
      target="_blank"
    >
      Browse
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Imported objects</h3>
      <ul
        slot="body"
        class="no_billets">
        <li
          v-for="(item, key) in importedObjects"
          :key="(item + key)">
          <a
            :href="loadTask(key, item)"
            target="_blank">{{ key }}
          </a>
        </li>
      </ul>
    </modal-component>
  </div>
</template>

<script>
import BrowseMixin from './shared/browseMixin'

export default {
  mixins: [BrowseMixin]
}
</script>
