<template>
  <div
    v-if="validationSections.length"
    class="panel content soft-validation-box validation-warning"
  >
    <div class="header flex-separate">
      <h3>Soft Validation</h3>
    </div>
    <div class="body overflow-y-auto">
      <template
        v-for="(section, index) in validationSections"
        :key="index"
      >
        <div class="soft-validation-section">
          <div
            v-if="section.title || getFixPresent(section.list).length"
            class="soft-validation-section__header"
          >
            <h4
              v-if="section.title"
              class="soft-validation-section__title"
            >
              {{ section.title }}
            </h4>
            <VBtn
              v-if="getFixPresent(section.list).length"
              color="create"
              @click="runFix(getFixPresent(section.list))"
            >
              Fix all
            </VBtn>
          </div>
          <ul
            v-for="list in section.list"
            class="no_bullets"
          >
            <li
              class="soft-validation-item"
              v-for="(error, index) in list.soft_validations"
              :key="index"
            >
              <VTooltip :content="error.description">
                <IconWarning class="w-4 h-4 text-attention-color" />
              </VTooltip>

              <span
                class="soft-validation-item__message"
                v-html="error.message"
              />

              <div class="soft-validation-item__actions">
                <VBtn
                  v-if="error.fixable"
                  color="create"
                  variant="tonal"
                  @click="
                    runFix([
                      {
                        global_id: list.instance.global_id,
                        only_methods: [error.soft_validation_method]
                      }
                    ])
                  "
                >
                  Fix
                </VBtn>

                <template
                  v-for="(resolution, rIndex) in error.resolution"
                  :key="rIndex"
                >
                  <VTooltip
                    class="d-inline-block"
                    content="Fixable here (may leave page)"
                  >
                    <a
                      class="btn btn-default-icon btn-primary btn-tonal"
                      :href="resolution"
                    >
                      <IconWrench class="w-4 h-4" />
                    </a>
                  </VTooltip>
                </template>
              </div>
            </li>
          </ul>
          <hr
            v-if="index !== validationSections.length - 1"
            class="divisor soft-validation-divisor"
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { SoftValidation } from '@/routes/endpoints'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed } from 'vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import IconWrench from '@/components/Icon/IconWrench.vue'

const props = defineProps({
  validations: {
    type: Object,
    required: true
  }
})

const validationSections = computed(() =>
  Object.values(props.validations).filter((item) => item.list.length)
)

function runFix(fixItems) {
  const promises = fixItems.map((params) =>
    SoftValidation.fix(params.global_id, params)
  )

  Promise.all(promises).then((responses) => {
    const softValidations = responses.map((r) => r.body.soft_validations)
    const notFixed = []
      .concat(...softValidations)
      .filter((validation) => validation.fixed === 'fix_error')

    if (notFixed.length) {
      TW.workbench.alert.create(
        notFixed.map((f) => f.failure_message).join('; '),
        'error'
      )
    } else {
      location.reload()
    }
  })
}

function getFixPresent(list) {
  return list
    .map((item) => ({
      global_id: item.instance.global_id,
      only_methods: item.soft_validations
        .filter((v) => v.fixable)
        .map((item) => item.soft_validation_method)
    }))
    .filter((item) => item.only_methods.length)
}
</script>
<style lang="scss" scoped>
.soft-validation-box.validation-warning {
  border-left: 4px solid var(--color-warning);
}
.soft-validation-box {
  background-color: var(--panel-bg-color);
  background-image: linear-gradient(
    var(--soft-validation-bg-color),
    var(--soft-validation-bg-color)
  );
  color: var(--text-color);
  .body {
    padding: 12px;
  }
  .header {
    padding-left: 12px;
    padding-right: 12px;
  }
  ul {
    margin: 0px;
    padding: 0px;
  }
}

.soft-validation-title {
  font-size: var(--font-size-sm);
  font-weight: 600;
  margin: 0;
}

.soft-validation-section__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--spacing-xs);
  margin-bottom: 8px;
}

.soft-validation-section__title {
  font-size: var(--font-size-xs);
  font-weight: 600;
  color: var(--text-muted-color);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin: 0;
}

.soft-validation-item {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-xs);
  margin-top: 12px;
}

.soft-validation-item__message {
  flex: 1;
  min-width: 0;

  &:first-letter {
    text-transform: capitalize;
  }
}

.soft-validation-item__actions {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xxs);
  margin-left: auto;
  flex-shrink: 0;
}

.soft-validation-divisor {
  height: 1px;
  background: var(--border-color);
  border: 0;
  margin: 12px 0;
}
</style>
