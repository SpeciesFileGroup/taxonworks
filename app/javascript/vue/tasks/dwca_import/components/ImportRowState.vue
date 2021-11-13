<template>
  <td>
    <template v-if="importedCount">
      <template v-if="importedCount === 1">
        <a
          v-for="(item, key) in importedObjects"
          :key="key"
          :href="taskUrl(key, item)"
          target="_blank"
          v-html="row.status"/>
      </template>
      <a
        v-else
        v-html="row.status"
        @click="openModal"/>
      <modal-component
        v-if="showModal"
        @close="showModal = false">
        <template #header>
          <h3>Imported objects</h3>
        </template>
        <template #body>
          <ul class="no_billets">
            <li
              v-for="(item, key) in importedObjects"
              :key="(item + key)">
              <a
                :href="loadTask(key, item)"
                target="_blank">{{ key }}
              </a>
            </li>
          </ul>
        </template>
      </modal-component>
    </template>
    <template v-else>
      <template v-if="importedErrors">
        <modal-component
          v-if="showErrors"
          @close="showErrors = false">
          <template #header>
            <h3>Errors</h3>
          </template>
          <template #body>
            <div>
              <template
                v-for="(messages, typeError) in importedErrors.messages"
                :key="typeError">
                <span
                  class="soft_validation"
                  data-icon="warning">
                  {{ typeError }}
                </span>
                <ul>
                  <li
                    v-for="error in messages"
                    v-html="error"/>
                </ul>
              </template>
            </div>
          </template>
        </modal-component>
        <a
          class="red"
          @click="showErrors = true"
          v-html="row.status"/>
      </template>
      <span
        v-else
        v-html="row.status"/>
    </template>
  </td>
</template>

<script>

import ButtonMixin from './shared/browseMixin'

export default {
  mixins: [ButtonMixin]
}
</script>
