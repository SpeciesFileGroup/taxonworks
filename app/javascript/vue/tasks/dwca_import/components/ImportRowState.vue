<template>
  <td>
    <template v-if="importedCount">
      <template v-if="importedCount === 1">
        <a
          v-for="(item, key) in importedObjects"
          :key="key"
          :href="taskUrl(key, item)"
          target="_blank"
          v-html="row.status"
        />
      </template>
      <span
        v-else
        v-html="row.status"
        :style="style"
        @click="openModal"
      />
      <modal-component
        v-if="showModal"
        @close="showModal = false"
      >
        <template #header>
          <h3>Imported objects</h3>
        </template>
        <template #body>
          <ul class="no_billets">
            <li
              v-for="(item, key) in importedObjects"
              :key="item + key"
            >
              <a
                :href="loadTask(key, item)"
                target="_blank"
                >{{ key }}
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
          @close="showErrors = false"
        >
          <template #header>
            <h3>Errors</h3>
          </template>
          <template #body>
            <div>
              <template
                v-for="(messages, typeError) in importedErrors.messages"
                :key="typeError"
              >
                <VIcon
                  name="attention"
                  color="attention"
                  small
                />
                <span>
                  {{ typeError }}
                </span>
                <ul>
                  <li
                    v-for="(error, index) in messages"
                    :key="index"
                    v-html="error"
                  />
                </ul>
              </template>
            </div>
          </template>
        </modal-component>
        <a
          class="cursor-pointer"
          :style="style"
          v-html="row.status"
          @click="() => (showErrors = true)"
        />
      </template>
      <span
        v-else
        :style="style"
        v-html="row.status"
      />
    </template>
  </td>
</template>

<script>
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonMixin from './shared/browseMixin'
import importColors from '../const/importColors'

export default {
  components: {
    VIcon
  },

  mixins: [ButtonMixin],

  computed: {
    style() {
      return {
        color: `var(${importColors[this.row.status]})`
      }
    }
  }
}
</script>
