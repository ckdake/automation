resource "aws_resourceexplorer2_index" "resource_explorer_aggregator" {
  type = "AGGREGATOR"
}

resource "aws_resourceexplorer2_view" "resource_explorer_view" {
  name         = "resourceexploreraggregator"
  default_view = true

  included_property {
    name = "tags"
  }

  depends_on = [aws_resourceexplorer2_index.resource_explorer_aggregator]
}
