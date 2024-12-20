resource "aws_resourceexplorer2_index" "resource_explorer_aggregator" {
  type = "AGGREGATOR"

  tags = local.tags
}

resource "aws_resourceexplorer2_view" "resource_explorer_view" {
  name         = "resourceexploreraggregator"
  default_view = true

  included_property {
    name = "tags"
  }

  tags = local.tags

  depends_on = [aws_resourceexplorer2_index.resource_explorer_aggregator]
}
