<template>
  <div
    v-if="validationSections.length"
    class="tw-card soft-validation-box validation-warning"
  >
    <div class="tw-card-header">
      <span class="card-icon-chip soft-validation-chip">
        <IconWarning />
      </span>
      <h2 class="tw-card-title">Soft validation</h2>
      <VBadge
        class="soft-validation-count"
        color="yellow"
        radius="full"
      >
        {{ validationCount }}
      </VBadge>
    </div>
    <div class="tw-card-body overflow-y-auto">
      <template
        v-for="(section, index) in validationSections"
        :key="index"
      >
        <div class="soft-validation-section">
          <div
            v-if="section.title || getFixableCount(section.list)"
            class="soft-validation-section__header"
          >
            <h4
              v-if="section.title"
              class="soft-validation-section__title"
            >
              {{ section.title }}
            </h4>
            <VBtn
              v-if="getFixableCount(section.list)"
              class="horizontal-left-content gap-xsmall"
              color="create"
              variant="tonal"
              :title="`Run all fixes (${getFixableCount(section.list)})`"
              @click="runFix(getFixPresent(section.list))"
            >
              <IconWandSparkles class="w-4 h-4" />
              <span>({{ getFixableCount(section.list) }})</span>
            </VBtn>
          </div>
          <ul
            class="no_bullets soft-validation-list"
            :class="{
              'soft-validation-list--with-actions': hasFixes(section.list)
            }"
          >
            <template
              v-for="(list, listIndex) in section.list"
              :key="listIndex"
            >
              <li
                class="soft-validation-item"
                v-for="(error, index) in list.soft_validations"
                :key="`${listIndex}-${index}`"
              >
                <VTooltip :content="error.description">
                  <IconWarning class="w-4 h-4 soft-validation-item__icon" />
                </VTooltip>

                <span
                  class="soft-validation-item__message"
                  v-html="error.message"
                />

                <div
                  v-if="hasFixes(section.list)"
                  class="soft-validation-item__actions"
                >
                  <VBtn
                    v-if="error.fixable"
                    icon
                    variant="tonal"
                    color="create"
                    title="Run fix"
                    @click="
                      runFix([
                        {
                          global_id: list.instance.global_id,
                          only_methods: [error.soft_validation_method]
                        }
                      ])
                    "
                  >
                    <IconWandSparkles class="w-4 h-4" />
                  </VBtn>

                  <template
                    v-for="(resolution, rIndex) in error.resolution"
                    :key="rIndex"
                  >
                    <VTooltip
                      class="d-inline-block"
                      content="Fix manually (may leave this page)"
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
            </template>
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
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import { computed } from 'vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import IconWrench from '@/components/Icon/IconWrench.vue'
import IconWandSparkles from '@/components/Icon/IconWandSparkles.vue'

const props = defineProps({
  validations: {
    type: Object,
    required: true
  }
})

const validationSections = computed(() =>
  Object.values(props.validations).filter((item) => item.list.length)
)

const validationCount = computed(() =>
  validationSections.value.reduce(
    (total, section) =>
      total +
      section.list.reduce((acc, item) => acc + item.soft_validations.length, 0),
    0
  )
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

function hasFixes(list) {
  return list.some((item) =>
    item.soft_validations.some(
      (validation) => validation.fixable || validation.resolution?.length
    )
  )
}

function getFixableCount(list) {
  return getFixPresent(list).reduce(
    (total, item) => total + item.only_methods.length,
    0
  )
}
</script>
<style lang="scss" scoped>
.soft-validation-box {
  display: flex;
  flex-direction: column;

  &.validation-warning {
    // Half-strength --color-soft-warning-bg, keeping its light/dark variants
    --soft-validation-tint: color-mix(
      in srgb,
      var(--color-soft-warning-bg) 20%,
      transparent
    );

    border-left: 4px solid var(--badge-yellow-bg);
    background-image: linear-gradient(
      var(--soft-validation-tint),
      var(--soft-validation-tint)
    );
  }
}

.soft-validation-chip {
  color: var(--color-warning-on-surface);
}

.soft-validation-count {
  margin-left: auto;
}

.soft-validation-item__icon {
  color: var(--color-warning-on-surface);
  cursor: help;
}

.soft-validation-section__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--spacing-xs);
  margin-bottom: var(--spacing-xs);
}

.soft-validation-section__title {
  font-size: var(--font-size-sm);
  font-weight: 600;
  margin: 0;
}

.soft-validation-list {
  display: grid;
  grid-template-columns: auto 1fr;
  align-items: start;
  column-gap: var(--spacing-xs);
  row-gap: var(--spacing-sm);
  margin: var(--spacing-sm) 0 0;
  padding: 0;
}

.soft-validation-list--with-actions {
  grid-template-columns: auto 1fr auto;
}

.soft-validation-item {
  display: contents;
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
  justify-self: start;
  gap: var(--spacing-xs);
}

.soft-validation-divisor {
  height: 0px;
  background: var(--border-color);
  border: 0;
  margin: var(--spacing-md) 0;
}
</style>
