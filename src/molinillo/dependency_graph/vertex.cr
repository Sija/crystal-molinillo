class Molinillo::DependencyGraph::Vertex(P, R)
  property root = false
  property name : String
  property payload : P
  getter outgoing_edges : Array(Edge(P, R))
  getter incoming_edges : Array(Edge(P, R))

  def initialize(@name, @payload : P)
    @outgoing_edges = Array(Edge(P, R)).new
    @incoming_edges = Array(Edge(P, R)).new
  end

  def successors
    outgoing_edges.map &.destination
  end

  def ==(other)
    super || (
      name == other.name &&
        payload == other.payload &&
        successors.to_set == other.successors.to_set
    )
  end

  # Is there a path from `self` to `other` following edges in the
  # dependency graph?
  # @return true iff there is a path following edges within this {#graph}
  def path_to?(other)
    false
  end
end