 <template>
  <VModal>
    <template #header>
      <h3>
        Insert a copy of a key: the root of the inserted key will be added to
        the leads visible here.
      </h3>
    </template>

    <template #body>
      <div v-if="isLoading">
        <VSpinner legend="Loading keys..."/>
      </div>

      <div v-if="keys.length > 0">
        <ul class="no_bullets">
          <li
            v-for="k in keys"
            :key="k.id"
          >
            <label>
              <input
                type="radio"
                :value="k.id"
                v-model="selectedKeyId"
              />
              {{ k.text }}
            </label>
          </li>
        </ul>
      </div>
      <div v-else-if="!isLoading">
        There are no keys other than the current one, which can't be inserted.
      </div>
    </template>

    <template #footer>
      <VBtn
        color="submit"
        medium
        @click="() => emit('keySelected', selectedKeyId)"
        :disabled="!selectedKeyId"
      >
        Select key
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Lead } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import { useStore } from '../store/useStore.js'

const emit = defineEmits(['keySelected'])

const store = useStore()

const keys = ref([])
const isLoading = ref(true)
const selectedKeyId = ref(null)

onBeforeMount(() => {
  Lead.where()
    .then(({ body }) => {
      keys.value = body.filter(
        // Don't include this key.
        (key) => key.id != store.root.id
      )
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
})

</script>