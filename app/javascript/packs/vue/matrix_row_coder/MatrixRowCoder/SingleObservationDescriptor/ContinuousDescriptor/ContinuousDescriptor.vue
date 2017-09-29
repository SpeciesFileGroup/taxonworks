<template>
    <div class="continuous-descriptor">
        <summary-view
            v-bind:descriptor="descriptor">

            <label>
                Amount:
                <input type="number" :value="continuousValue" @input="updateContinuousValue">
            </label>
            <unit-selector v-model="continuousUnit"></unit-selector>
            <button
                type="button"
                @click="removeObservation">
                Remove
            </button>
        </summary-view>

        <single-observation-zoomed-view
            v-bind:descriptor="descriptor"
            v-bind:observation="observation">

            <p>
                <label>
                    Amount:
                    <input type="number" :value="continuousValue" @input="updateContinuousValue">
                </label>
            </p>
            <p>
                <unit-selector v-model="continuousUnit"></unit-selector>
            </p>
        </single-observation-zoomed-view>
    </div>
</template>

<style lang="stylus" src="./ContinuousDescriptor.styl"></style>

<script>
    import { GetterNames } from '../../../store/getters/getters';
    import { MutationNames } from '../../../store/mutations/mutations';
    import SingleObservationDescriptor from '../SingleObservationDescriptor';
    import UnitSelector from '../../UnitSelector/UnitSelector.vue';

    module.exports = {
        mixins: [SingleObservationDescriptor],
        name: 'continuous-descriptor',
        computed: {
            continuousValue: function() {
                return this.$store.getters[GetterNames.GetContinuousValueFor](this.$props.descriptor.id);
            },
            continuousUnit: {
                get() {
                    return this.$store.getters[GetterNames.GetContinuousUnitFor](this.$props.descriptor.id);
                },
                set(unit) {
                    this.$store.commit(MutationNames.SetContinuousUnit, {
                        descriptorId: this.$props.descriptor.id,
                        continuousUnit: unit
                    });
                }
            }
        },
        methods: {
            updateContinuousValue(event) {
                this.$store.commit(MutationNames.SetContinuousValue, {
                    descriptorId: this.$props.descriptor.id,
                    continuousValue: event.target.value
                })
            },
            removeObservation(event) {
                console.log(`removeObservation`);
            }
        },
        components: {
            UnitSelector
        }
    };
</script>