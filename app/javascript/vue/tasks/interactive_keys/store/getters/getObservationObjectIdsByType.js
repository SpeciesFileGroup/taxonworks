import sides from "../../const/filterings"
import { intersectArrays } from "@/helpers"

export default (state) => {
  return (selectionArray, observationObjectType) => {
    const m = state.observationMatrix

    const remaining = !selectionArray.includes(sides.Remaining) ? undefined :
      m.remaining.filter((o) => o.object.observation_object_type == observationObjectType).map((o) => o.object.observation_object_id)

    const eliminated = !selectionArray.includes(sides.Eliminated) ? undefined :
      m.eliminated.filter((o) => o.object.observation_object_type == observationObjectType).map((o) => o.object.observation_object_id)

    const eliminatedForKey = !selectionArray.includes(sides.EliminatedForKey) ? undefined :
      m.eliminated_for_key.filter((o) => o.object.observation_object_type == observationObjectType).map((o) => o.object.observation_object_id)

    const both = !selectionArray.includes(sides.Both) ? undefined :
      intersectArrays(remaining, eliminated)

    return {
      remaining,
      eliminated,
      eliminatedForKey,
      both
    }
  }
}
