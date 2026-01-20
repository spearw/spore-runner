## encounter_config_list.gd
## A Resource that holds an array of all encounter configs for random selection.
class_name EncounterConfigList
extends Resource

@export var configs: Array[EncounterConfig]

## Picks a random config from the list.
func pick_random() -> EncounterConfig:
	if configs.is_empty():
		return null
	return configs.pick_random()
