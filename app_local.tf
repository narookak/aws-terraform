locals {
  app_tags_asg_format = ["${null_resource.tags_as_list_of_maps.*.triggers}"]
}

resource "null_resource" "app_tags_as_list_of_maps" {
  count = "${length(keys(var.app_tags_as_map))}"

  triggers = "${map(
    "key", "${element(keys(var.app_tags_as_map), count.index)}",
    "value", "${element(values(var.app_tags_as_map), count.index)}",
    "propagate_at_launch", "true"
  )}"
}